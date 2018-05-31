//
//  ZHAFHTTPSessionManager.h
//  ZHHttpRequestQueueManagerDemo
//
//  Created by  孔凡伍 on 2018/5/31.
//  Copyright © 2018年 pjg. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface ZHAFHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)manager;

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end
