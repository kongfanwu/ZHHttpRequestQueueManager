//
//  ZHHTTPRequestQueueManager.m
//  zhenghao
//
//  Created by  孔凡伍 on 2018/5/28.
//  Copyright © 2018年 moreunion. All rights reserved.
//

#import "ZHHTTPRequestQueueManager.h"
#import <AFHTTPSessionManager.h>

@interface ZHHTTPRequestQueueManager()

/** <##> */
@property (nonatomic, copy) RequestsResponse response;
/** <##> */
@property (nonatomic) dispatch_group_t request_blocks_group;
/** <##> */
@property (nonatomic, strong) NSMutableArray <ZHHTTPResponse *> *responses;

@end

@implementation ZHHTTPRequestQueueManager

#pragma mark - Public

- (instancetype)initWithRequest:(NSArray <ZHHTTPRequest *> *)requests
{
    self = [super init];
    if (self) {
        self.requests = requests;
        self.responses = [NSMutableArray arrayWithCapacity:self.requests.count];
    }
    return self;
}

- (void)startRequestResponse:(RequestsResponse)response {
    self.response = response;
    
    if (!self.requests.count) return;
    
    NSArray *priorityArray = [self arrayFromRequestPriority];
    // 1 所有请求优先级相同。并行并回调
    if (priorityArray.count == 1) {
        [self requestConcurrent];
    }
    // 2 所有请求优先级有的不同。串行并回调
    else {
        [self requestSerialPriorityArray:priorityArray];
    }
}

#pragma mark - Private

/**
 串行请求
 */
- (void)requestSerialPriorityArray:(NSArray *)priorityArray {
    self.request_blocks_group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_async(self.request_blocks_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSArray *subPrioritys in priorityArray) {
            for (ZHHTTPRequest *request in subPrioritys) {
                [self request:request complete:^{
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //DISPATCH_TIME_FOREVER
            }
        }
        
        dispatch_group_notify(self.request_blocks_group, dispatch_get_main_queue(), ^{
            if (self.response) {
                __block BOOL success = YES;
                __block NSError *error = nil;
                // 依据请求顺序排序
                [self.responses enumerateObjectsUsingBlock:^(ZHHTTPResponse * _Nonnull response, NSUInteger idx, BOOL * _Nonnull responseStop) {
                    // 一个失败 success 都会 NO
                    if (!response.success && success) {
                        error = response.error;
                        success = NO;
                    }
                }];
                
                self.response(success, self.responses, error);
            }
        });
    });
}

/**
 并行请求
 */
- (void)requestConcurrent {
    self.request_blocks_group = dispatch_group_create();
    
    for (ZHHTTPRequest *request in self.requests) {
        dispatch_group_enter(self.request_blocks_group);
        dispatch_group_async(self.request_blocks_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __weak typeof(self) _self = self;
            [self request:request complete:^{
                __strong typeof(_self) self = _self;
                [self dispatchGroupLeave];
            }];
        });
    }
    
    dispatch_group_notify(self.request_blocks_group, dispatch_get_main_queue(), ^{
        if (self.response) {
            __block BOOL success = YES;
            __block NSError *error = nil;
            // 依据请求顺序排序
            NSMutableArray *newResponses = NSMutableArray.new;
            [self.requests enumerateObjectsUsingBlock:^(ZHHTTPRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull requestStop) {
                [self.responses enumerateObjectsUsingBlock:^(ZHHTTPResponse * _Nonnull response, NSUInteger idx, BOOL * _Nonnull responseStop) {
                    // 一个失败 success 都会 NO
                    if (!response.success && success) {
                        error = response.error;
                        success = NO;
                    }
                    if ([request.ID isEqualToString:response.ID]) {
                        [newResponses addObject:response];
                    }
                }];
            }];
            self.responses = newResponses;
            
            self.response(success, self.responses, error);
        }
        self.request_blocks_group = NULL;
    });
}

- (void)dispatchGroupLeave {
    if (self.request_blocks_group) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_group_leave(self.request_blocks_group);
        });
    }
}

/*
- (void)request:(ZHHTTPRequest *)request complete:(void(^)())complete {
    NetworkRequestMethodENUM methodType = request.methodType ==  ZHHTTPRequestMethodTypeGET ? NetworkRequestMethodGET : NetworkRequestMethodPOST;
    [HttpRequestSigleton requestWithRequestMethod:methodType methodName:request.url Params:request.params Optional:nil Success:^(id  _Nonnull json) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request.response) {
                BOOL success = YES;
                id newJson = json;
                NSError *error;
                if ([json[@"error_code"] integerValue] != 0) {
                    success = NO;
                    newJson = nil;
                    error = [[NSError alloc] initWithDomain:@"ZHHTTPRequestQueueManager" code:[json[@"error_code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"requestId:%@ %@", request.ID, json[@"error_msg"]]}];
                }
                ZHHTTPResponse *response = [[ZHHTTPResponse alloc] initId:request.ID success:success json:newJson error:error];
                response.modelArray = request.response(response);
                
                [self.responses addObject:response];
            }
            
            if (complete) complete();
        });
    } Failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request.response) {
                ZHHTTPResponse *response = [[ZHHTTPResponse alloc] initId:request.ID success:NO json:nil error:error];
                response.modelArray = request.response(response);
            }
            
            if (complete) complete();
        });
    }];
}
*/

- (void)request:(ZHHTTPRequest *)request complete:(void(^)(void))complete {
    NSString *methodType = [request stringFromMethodType];
    ZHAFHTTPSessionManager *manager = [ZHAFHTTPSessionManager manager];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithHTTPMethod:methodType URLString:request.url parameters:request.params uploadProgress:request.uploadProgress downloadProgress:request.downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        if (request.response) {
            BOOL success = YES;
            id newJson = responseObject;
            NSError *error;
            if ([responseObject[@"error_code"] integerValue] != 0) {
                success = NO;
                newJson = nil;
                error = [[NSError alloc] initWithDomain:@"ZHHTTPRequestQueueManager" code:[responseObject[@"error_code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"requestId:%@ %@", request.ID, responseObject[@"error_msg"]]}];
            }
            ZHHTTPResponse *response = [[ZHHTTPResponse alloc] initId:request.ID success:success json:newJson error:error];
            response.modelArray = request.response(response);
            
            [self.responses addObject:response];
        }
        
        if (complete) complete();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (request.response) {
            ZHHTTPResponse *response = [[ZHHTTPResponse alloc] initId:request.ID success:NO json:nil error:error];
            response.modelArray = request.response(response);
        }
        
        if (complete) complete();
    }];
    [dataTask resume];
}
/**
 根据请求优先级，相同的组成一个数组，最后返回一个大数组

 @return array @[@[], @[]]
 */
- (NSArray *)arrayFromRequestPriority {
    NSMutableDictionary *priorityDic = NSMutableDictionary.new;
    for (int i = 0; i < self.requests.count; i++) {
        ZHHTTPRequest *request = self.requests[i];
        NSString *requestPriorityString = @(request.requestPriority).stringValue;
        if (priorityDic[requestPriorityString] == nil) {
            priorityDic[requestPriorityString] = NSMutableArray.new;
        }
        [((NSMutableArray *)priorityDic[requestPriorityString]) addObject:request];
    }
    
    // 优先级排序
    NSArray *priorityDicKey = [priorityDic.allKeys sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        int value1 = [obj1 intValue];
        int value2 = [obj2 intValue];
        if (value1 > value2) {
            return NSOrderedAscending;
        }else if (value1 == value2){
            return NSOrderedSame;
        }else{
            return NSOrderedDescending;
        }
    }];
    
    NSMutableArray *priorityArray = NSMutableArray.new;
    [priorityDicKey enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [priorityArray addObject:priorityDic[obj]];
    }];
    
    return priorityArray;
}
@end
