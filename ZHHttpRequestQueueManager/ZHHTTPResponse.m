//
//  ZHHTTPResponse.m
//  zhenghao
//
//  Created by  孔凡伍 on 2018/5/28.
//  Copyright © 2018年 moreunion. All rights reserved.
//

#import "ZHHTTPResponse.h"

@implementation ZHHTTPResponse

- (instancetype)initId:(NSString *)ID success:(BOOL)success json:(id)json error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.ID = ID;
        self.success = success;
        self.json = json;
        self.error = error;
    }
    return self;
}

@end
