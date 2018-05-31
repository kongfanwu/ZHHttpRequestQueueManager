//
//  ZHHTTPRequestQueueManager.h
//  zhenghao
//
//  Created by  孔凡伍 on 2018/5/28.
//  Copyright © 2018年 moreunion. All rights reserved.
//
/* 功能 1 并行请求统一回调。 不要设置依赖 addDependency:
   功能 2 串行请求统一回调。 需要设置依赖 addDependency:
 */
/*
 ZHHTTPRequest *request = [[ZHHTTPRequest alloc] initWithId:@"1" method:ZHHTTPRequestMethodTypeGET url:@"getRecommend" params:@{@"type":@"9",@"limit":@"1"} response:^(ZHHTTPResponse *response) {
     if (response.success) {
         return @[@"1", @"2"];
     }
     return request.empty;
 }];
 
 ZHHTTPRequest *request2 = [[ZHHTTPRequest alloc] initWithId:@"2" method:ZHHTTPRequestMethodTypeGET url:@"getRecommend" params:@{@"type":@"9",@"limit":@"1"} response:^(ZHHTTPResponse *response) {
     if (response.success) {
         return @[@"3", @"4"];
     }
     return request.empty;
 }];
 
 [request2 addDependency:request];
 
 ZHHTTPRequestQueueManager *manager = [[ZHHTTPRequestQueueManager alloc] initWithRequest:@[request2, request]];
 [manager startRequestResponse:^(BOOL success, NSArray<ZHHTTPResponse *> *responses, NSError *error) {
 }];
 */

#import <Foundation/Foundation.h>
#import "ZHHTTPRequest.h"
#import "ZHHTTPResponse.h"
#import "ZHAFHTTPSessionManager.h"

/**
 全部成功后回调

 @param success YES 成功
 @param responses 所有请求成功后的 response 数组
 @param error 失败 
 */
typedef void(^RequestsResponse)(BOOL success, NSArray <ZHHTTPResponse *> *responses, NSError *error);

@interface ZHHTTPRequestQueueManager : NSObject

/** 所有请求 */
@property (nonatomic, strong) NSArray <ZHHTTPRequest *> *requests;

/**
 初始化方法

 @param requests 所有请求
 @return self
 */
- (instancetype)initWithRequest:(NSArray <ZHHTTPRequest *> *)requests;


/**
 开始请求

 @param response 全部成功后回调
 */
- (void)startRequestResponse:(RequestsResponse)response;

@end
