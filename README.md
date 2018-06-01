# ZHHttpRequestQueueManager
功能 1 并行请求统一回调。 不要设置依赖 addDependency:   
功能 2 串行请求统一回调。 需要设置依赖 addDependency:

## 自定义网络请求库修改   
ZHHTTPRequestQueueManager.m 类    
- (void)request:(ZHHTTPRequest *)request complete:(void(^)())complete 方法。替换你的网络请求。   

## 示例
```
ZHHTTPRequest *request = [[ZHHTTPRequest alloc] initWithId:@"1" method:ZHHTTPRequestMethodTypeGET url:@"getRecommend" params:@{@"type":@"9",@"limit":@"1"} response:^(ZHHTTPResponse *response) {
     if (response.success) {
        // 返回 model 数组
         return @[@"1", @"2"];
     }
     return ZHHTTPRequest.empty;
 }];
 
 ZHHTTPRequest *request2 = [[ZHHTTPRequest alloc] initWithId:@"2" method:ZHHTTPRequestMethodTypeGET url:@"getRecommend" params:@{@"type":@"9",@"limit":@"1"} response:^(ZHHTTPResponse *response) {
     if (response.success) {
         return @[@"3", @"4"];
     }
     return ZHHTTPRequest.empty;
 }];
 
 /* 注意：
 *  设置依赖就是串行请求。不设置就是并行请求。
 *  其他注意事项看方法注释
 */ 
 [request2 addDependency:request];
 
 ZHHTTPRequestQueueManager *manager = [[ZHHTTPRequestQueueManager alloc] initWithRequest:@[request2, request]];
 [manager startRequestResponse:^(BOOL success, NSArray<ZHHTTPResponse *> *responses, NSError *error) {
     if (response.success) {
         // ...
     }
 }];
```
