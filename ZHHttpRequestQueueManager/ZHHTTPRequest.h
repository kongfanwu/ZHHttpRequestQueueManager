//
//  ZHHTTPRequest.h
//  zhenghao
//
//  Created by  孔凡伍 on 2018/5/28.
//  Copyright © 2018年 moreunion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZHHTTPResponse;

/** 请求类型 */
typedef NS_ENUM(NSInteger, ZHHTTPRequestMethodType) {
    ZHHTTPRequestMethodTypeGET,
    ZHHTTPRequestMethodTypePOST
};

/** 请求优先级 */
typedef NS_ENUM(NSInteger, ZHHTTPRequestPriority) {
    ZHHTTPRequestPriorityLow = 50,     // 低
    ZHHTTPRequestPriorityNormal = 100, // 中 默认
    ZHHTTPRequestPriorityHigh = 150,   // 高
};

/**
 请求成功后回调

 @param response 响应对象
 @return 返回 model array. 没有可返回空数组
 */
typedef NSArray * (^ResponseHandle)(ZHHTTPResponse *response);

@interface ZHHTTPRequest : NSObject

/** id */
@property (nonatomic, copy) NSString *ID;
/** 方法类型 */
@property (nonatomic) ZHHTTPRequestMethodType methodType;
/** 请求url */
@property (nonatomic, copy) NSString *url;
/** 参数 */
@property (nonatomic, strong) NSDictionary *params;
/** 成功失败响应 */
@property (nonatomic, copy) ResponseHandle response;

/** 依赖优先级 */
@property (nonatomic, readonly) ZHHTTPRequestPriority requestPriority;

/** 上传回调 */
@property (nonatomic, copy) void (^uploadProgress)(NSProgress *uploadProgress);
/** 下载回调 */
@property (nonatomic, copy) void (^downloadProgress)(NSProgress *downloadProgress);

/**
 初始化方法

 @param ID 请求id
 @param methodType 方法类型
 @param url 请求url
 @param params 参数
 @param response 成功失败响应
 @return self
 */
- (instancetype)initWithId:(NSString *)ID method:(ZHHTTPRequestMethodType)methodType url:(NSString *)url params:(NSDictionary *)params response:(ResponseHandle)response;

/**
 添加依赖
 B C 都依赖 A 时。B C 先后执行顺序取决于请求顺序数组 requests
 注意：self 被依赖后，不要在设置依赖其他 request 例如
 错误：A 依赖 B . B 依赖 C
 正确：B 依赖 C . A 依赖 B
 @param request 被依赖的 request 先执行
 */
- (void)addDependency:(ZHHTTPRequest *)request;

/** 返回 nil 解决语法报错问题 */
+ (NSArray *)empty;

/**
 返回方法类型字符串
 
 @return string
 */
- (NSString *)stringFromMethodType;

@end
