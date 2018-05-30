//
//  ZHHTTPResponse.h
//  zhenghao
//
//  Created by  孔凡伍 on 2018/5/28.
//  Copyright © 2018年 moreunion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHHTTPResponse : NSObject

/** id */
@property (nonatomic, copy) NSString *ID;
/** YES 请求成功 */
@property (nonatomic) BOOL success;
/** 元数据 */
@property (nonatomic, strong) id json;
/** 失败error */
@property (nonatomic, strong) NSError *error;

/** 元数据格式化成 model array */
@property (nonatomic, strong) NSArray *modelArray;

/**
 初始化

 @param ID 请求id
 @param success 请求成功失败
 @param json 元数据
 @param error 失败
 @return self
 */
- (instancetype)initId:(NSString *)ID success:(BOOL)success json:(id)json error:(NSError *)error;

@end
