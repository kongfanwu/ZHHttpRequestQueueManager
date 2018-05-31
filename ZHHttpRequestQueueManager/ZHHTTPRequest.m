//
//  ZHHTTPRequest.m
//  zhenghao
//
//  Created by  孔凡伍 on 2018/5/28.
//  Copyright © 2018年 moreunion. All rights reserved.
//

#import "ZHHTTPRequest.h"
#import "ZHHTTPResponse.h"

@interface ZHHTTPRequest()

/** <##> */
@property (nonatomic) ZHHTTPRequestPriority requestPriority;

@end

@implementation ZHHTTPRequest

- (instancetype)initWithId:(NSString *)ID method:(ZHHTTPRequestMethodType)methodType url:(NSString *)url params:(NSDictionary *)params response:(ResponseHandle)response
{
    self = [super init];
    if (self) {
        self.ID = ID;
        self.methodType = methodType;
        self.url = url;
        self.params = params;
        self.response = response;
        
        self.requestPriority = ZHHTTPRequestPriorityNormal;
    }
    return self;
}

/**
 添加依赖
 B C 都依赖 A 时。B C 先后执行顺序取决于请求顺序数组 requests
 注意：self 被依赖后，不要在设置依赖其他 request 例如
 错误：A 依赖 B . B 依赖 C
 正确：B 依赖 C . A 依赖 B
 @param request 被依赖的 request 先执行
 */
- (void)addDependency:(ZHHTTPRequest *)request {
    self.requestPriority = request.requestPriority - 1;
}

/** 返回 nil 解决语法报错问题 */
+ (id)empty {
    return (NSArray *)nil;
}

/**
 返回方法类型字符串

 @return string
 */
- (NSString *)stringFromMethodType {
    switch (self.methodType) {
        case ZHHTTPRequestMethodTypeGET: {
            return @"GET";
            break;
        }
        case ZHHTTPRequestMethodTypePOST: {
            return @"POST";
            break;
        }
    }
    return @"GET";
}

@end
