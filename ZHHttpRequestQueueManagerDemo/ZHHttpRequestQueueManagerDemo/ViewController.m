//
//  ViewController.m
//  ZHHttpRequestQueueManagerDemo
//
//  Created by  孔凡伍 on 2018/5/31.
//  Copyright © 2018年 pjg. All rights reserved.
//

#import "ViewController.h"
#import "ZHHTTPRequestQueueManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSString *url = @"http://gc.ditu.aliyun.com/regeocoding?l=39.938133,116.395739&type=001";
    NSString *url = @"http://192.168.7.40:88/deviceRegister?idfa=06DE06C4-B640-403D-A89D-A06A099C51D5&platform=1";
    
    ZHHTTPRequest *request = [[ZHHTTPRequest alloc] initWithId:@"1" method:ZHHTTPRequestMethodTypeGET url:url params:nil response:^(ZHHTTPResponse *response) {
        if (response.success) {
            return @[@"1", @"2"];
        }
        return ZHHTTPRequest.empty;
    }];
    
    ZHHTTPRequest *request2 = [[ZHHTTPRequest alloc] initWithId:@"2" method:ZHHTTPRequestMethodTypeGET url:url params:nil response:^(ZHHTTPResponse *response) {
        if (response.success) {
            return @[@"3", @"4"];
        }
        return ZHHTTPRequest.empty;
    }];
    
    ZHHTTPRequestQueueManager *manager = [[ZHHTTPRequestQueueManager alloc] initWithRequest:@[request2, request]];
    [manager startRequestResponse:^(BOOL success, NSArray<ZHHTTPResponse *> *responses, NSError *error) {
        NSLog(@"%@", responses);
    }];
}


@end
