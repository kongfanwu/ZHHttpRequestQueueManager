# ZHHttpRequestQueueManager
功能 1 并行请求统一回调。 不要设置依赖 addDependency:   
功能 2 串行请求统一回调。 需要设置依赖 addDependency:

注意： 肯定会报错，需要修改    
ZHHTTPRequestQueueManager.m 类    
- (void)request:(ZHHTTPRequest *)request complete:(void(^)())complete 方法。替换你的网络请求。   

```
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
```
