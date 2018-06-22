//
//  WKJNetWorking.m
//  WKJNetWorking
//
//  Created by 王恺靖 on 2018/3/9.
//  Copyright © 2018年 WKJ. All rights reserved.
//

#import "WKJNetworking.h"
#import "AFNetworking.h"

#pragma mark - -----------WKJBuilder-----------
@interface WKJBuilder ()

@property (nonatomic, copy) NSString *wkj_fullURL;

@property (nonatomic, assign) NSTimeInterval wkj_timeoutSec;

@property (nonatomic, assign) WKJMediaType wkj_requestType;

@property (nonatomic, assign) WKJMediaType wkj_responseType;

@property (nonatomic, strong) NSMutableDictionary *cacheInfo;

@property (nonatomic, strong) NSDictionary *wkj_header;

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, copy) WKJCustomerResponse responseBlock;

+ (instancetype)defaultBuilder;

@end

@implementation WKJBuilder

+ (instancetype)defaultBuilder
{
    WKJBuilder *builder = [[WKJBuilder alloc] init];
    builder.wkj_timeoutSec = 15;
    builder.wkj_requestType = WKJMediaTypeFORM;
    builder.wkj_responseType = WKJMediaTypeJSON;
    return builder;
}

- (WKJTimeout)timeout
{
    __weak typeof(self) weakSelf = self;
    return ^(NSTimeInterval sec) {
        weakSelf.wkj_timeoutSec = sec;
        return weakSelf;
    };
}

- (WKJRequestType)requestType
{
    __weak typeof(self) weakSelf = self;
    return ^(WKJMediaType requestType) {
        weakSelf.wkj_requestType = requestType;
        return weakSelf;
    };
}

- (WKJResponseType)responesType
{
    __weak typeof(self) weakSelf = self;
    return ^(WKJMediaType responesType) {
        weakSelf.wkj_responseType = responesType;
        return weakSelf;
    };
}

- (WKJHeader)header
{
    __weak typeof(self) weakSelf = self;
    return ^(NSDictionary *header) {
        weakSelf.wkj_header = header;
        return weakSelf;
    };
}

- (WKJCached)cache
{
    __weak typeof(self) weakSelf = self;
    return ^(BOOL shouldCached) {
        NSString *key = [WKJNetCache getMD5String:weakSelf.wkj_fullURL];
        [weakSelf.cacheInfo setObject:@(shouldCached) forKey:key];
        return weakSelf;
    };
}

- (WKJRequestStart)request
{
    __weak typeof(self) weakSelf = self;
    return ^(void) {
        [weakSelf setupManager];
        
        WKJRequest *req = [WKJRequest new];
        [req setValue:weakSelf forKey:@"builder"];
        
        NSString *key = [WKJNetCache getMD5String:weakSelf.wkj_fullURL];
        NSNumber *cached = [weakSelf.cacheInfo objectForKey:key];
        cached = cached ? cached : @(NO);
        [req setValue:cached forKey:@"cached"];
        
        WKJResponse *rsp = [WKJResponse new];
        [req setValue:rsp forKey:@"rsp"];
        return req;
    };
}

- (NSMutableDictionary *)cacheInfo
{
    if (!_cacheInfo) {
        _cacheInfo = [[NSMutableDictionary alloc] init];
    }
    return _cacheInfo;
}

#pragma mark - Private
- (void)setupManager
{
    self.manager.requestSerializer.timeoutInterval = self.wkj_timeoutSec;
    
    switch (self.wkj_requestType) {
        case WKJMediaTypeFORM:
            self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
            
        case WKJMediaTypeJSON:
            self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
            
        default:
            WKJLog(@"requestType 仅支持 WKJMediaTypeFORM 及 WKJMediaTypeJSON");
            break;
    }
    
    switch (self.wkj_responseType) {
        case WKJMediaTypeXML:
            self.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
            
        case WKJMediaTypeJSON:
            self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
            
        case WKJMediaTypeData:
            self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
            
        default:
            WKJLog(@"responseType 不支持 WKJMediaTypeFORM");
            break;
    }
    
    [self.wkj_header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    NSSet *contentTypes = [NSSet setWithArray:@[@"application/json",
                                                @"text/html",
                                                @"text/json",
                                                @"text/plain",
                                                @"text/javascript",
                                                @"text/xml",
                                                @"image/*"]];
    
    self.manager.responseSerializer.acceptableContentTypes = contentTypes;
}

@end

#pragma mark - -----------WKJResponse-----------
@interface WKJResponse ()

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, copy) RequestProgress rp;

@property (nonatomic, copy) RequestSuccess rs;

@property (nonatomic, copy) RequestFail rf;

@end

@implementation WKJResponse

- (WKJProgress)progress
{
    __weak typeof(self) weakSelf = self;
    return ^(RequestProgress rp) {
        weakSelf.rp = rp;
        return weakSelf;
    };
}

- (WKJSuccess)success
{
    __weak typeof(self) weakSelf = self;
    return ^(RequestSuccess rs) {
        weakSelf.rs = rs;
        return weakSelf;
    };
}

- (WKJFail)fail
{
    __weak typeof(self) weakSelf = self;
    return ^(RequestFail rf) {
        weakSelf.rf = rf;
        return weakSelf;
    };
}

- (NSDictionary *)header
{
    return self.task.currentRequest.allHTTPHeaderFields;
}

@end

#pragma mark - -----------WKJRequest-----------
@interface WKJRequest ()

@property (nonatomic, strong) WKJBuilder *builder;

@property (nonatomic, strong) WKJResponse *rsp;

@property (nonatomic, assign) BOOL cached;

@end

@implementation WKJRequest

- (WKJGet)get
{
    __weak typeof(self) weakSelf = self;
    return ^(NSDictionary *params) {
        NSURLSessionDataTask *task = [weakSelf requestMethod:@"GET"
                                                      params:params
                                                   bodyBlock:nil];
        weakSelf.rsp.task = task;
        return weakSelf.rsp;
    };
}

- (WKJPost)post
{
    __weak typeof(self) weakSelf = self;
    return ^(NSDictionary *params) {
        NSURLSessionDataTask *task = [weakSelf requestMethod:@"POST"
                                                      params:params
                                                   bodyBlock:nil];
        weakSelf.rsp.task = task;
        return weakSelf.rsp;
    };
}

- (WKJUploadImages)uploadImages
{
    __weak typeof(self) weakSelf = self;
    return ^(NSDictionary *params, NSArray<UIImage *> *images, NSString *imagesKey) {
        NSURLSessionDataTask *task = [weakSelf uploadImages:images
                                                     params:params
                                                  imagesKey:imagesKey];
        weakSelf.rsp.task = task;
        return weakSelf.rsp;
    };
}

- (WKJUploadFile)uploadFile
{
    __weak typeof(self) weakSelf = self;
    return ^(NSString *path, NSString *fileKey) {
        NSURLSessionDataTask *task = [weakSelf uploadFile:path fileKey:fileKey];
        weakSelf.rsp.task = task;
        return weakSelf.rsp;
    };
}

- (WKJDownloadFile)downloadFile
{
    __weak typeof(self) weakSelf = self;
    return ^(NSString *savePath) {
        NSURLSessionDownloadTask *task = [weakSelf downLoadRequest:savePath];
        weakSelf.rsp.task = task;
        return weakSelf.rsp;
    };
}

#pragma mark - Private
- (NSURLSessionDataTask *)requestMethod:(NSString *)method
                                 params:(NSDictionary *)params
                              bodyBlock:(void (^)(id <AFMultipartFormData> formData))bodyBlock
{
    NSError *error = nil;
    NSURLSessionDataTask *dataTask = nil;
    NSMutableURLRequest *request = nil;
    
    if ([method isEqualToString:@"GET"]) {
        request = [self.builder.manager.requestSerializer requestWithMethod:@"GET" URLString:self.builder.wkj_fullURL parameters:params error:&error];
    }
    else {
        request = [self.builder.manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:self.builder.wkj_fullURL parameters:params constructingBodyWithBlock:bodyBlock error:&error];
    }
    
    if (error) {
        dispatch_async(self.builder.manager.completionQueue ?: dispatch_get_main_queue(), ^{
            !self.rsp.rf ?: self.rsp.rf(error);
        });
        return nil;
    }
    
    if (self.cached) {
        id cacheData = [WKJNetCache cacheForURL:self.builder.wkj_fullURL];
        if (cacheData) {
            dispatch_async(self.builder.manager.completionQueue ?: dispatch_get_main_queue(), ^{
                if (self.builder.responseBlock) {
                    self.builder.responseBlock(cacheData, nil, self.rsp.rs, self.rsp.rf);
                }
                else {
                    !self.rsp.rs ?: self.rsp.rs(cacheData);
                }
            });
        }
    }
    
    dataTask = [self.builder.manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
        if ([method isEqualToString:@"POST"] && self.rsp.rp) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.rsp.rp(uploadProgress.completedUnitCount,
                            uploadProgress.totalUnitCount);
            });
        }
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
        if ([method isEqualToString:@"GET"] && self.rsp.rp) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.rsp.rp(downloadProgress.completedUnitCount,
                            downloadProgress.totalUnitCount);
            });
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            // 取消请求的错误不予返回
            if (error.code != -999) {
                if (self.builder.responseBlock && self.rsp.rf) {
                    self.builder.responseBlock(responseObject, error, self.rsp.rs, self.rsp.rf);
                }
                else {
                    !self.rsp.rf ?: self.rsp.rf(error);
                }
            }
        }
        else {
            if (self.cached) {
                [WKJNetCache setHttpCache:responseObject URL:self.builder.wkj_fullURL];
            }
            
            if (self.builder.responseBlock && self.rsp.rs) {
                self.builder.responseBlock(responseObject, nil, self.rsp.rs, self.rsp.rf);
            }
            else {
                !self.rsp.rs ?: self.rsp.rs(responseObject);
            }
        }
    }];
    
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDownloadTask *)downLoadRequest:(NSString *)savePath
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.builder.wkj_fullURL]];
    
    NSURLSessionDownloadTask *downloadTask = [self.builder.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.rsp.rp(downloadProgress.completedUnitCount,
                        downloadProgress.totalUnitCount);
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:savePath ? savePath : @"Download"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        WKJLog(@"保存路径%@",filePath);
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            if (self.rsp.rf) {
                // 取消请求的错误不予返回
                error.code == -999 ?: self.rsp.rf(error);
            }
        }
        else {
            !self.rsp.rs ?: self.rsp.rs(filePath.absoluteString);
        }
    }];
    
    [downloadTask resume];
    return downloadTask;
}

#pragma mark - Setup BodyBlock Method
- (NSURLSessionDataTask *)uploadImages:(NSArray<UIImage *> *)images
                                params:(NSDictionary *)params
                             imagesKey:(NSString *)imagesKey
{
    NSURLSessionDataTask *task = [self requestMethod:@"POST" params:params bodyBlock:^(id<AFMultipartFormData> formData) {
        
        for (int i = 0; i < images.count; i++) {
            NSData *imageData = UIImageJPEGRepresentation(images[i], 0.8);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *timeStr = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",timeStr,i];
            [formData appendPartWithFileData:imageData name:imagesKey fileName:fileName mimeType:@"image/jpg"];
        }
    }];
    
    return task;
}

- (NSURLSessionDataTask *)uploadFile:(NSString *)path
                             fileKey:(NSString *)fileKey
{
    NSURLSessionDataTask *task = [self requestMethod:@"POST" params:nil bodyBlock:^(id<AFMultipartFormData> formData) {
        
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:fileKey error:&error];
        
        if (self.rsp.rf && error) {
            self.rsp.rf(error);
        }
    }];
    
    return task;
}

@end

#pragma mark - -----------WKJNetworking-----------
@implementation WKJNetworking

static NSString *wkj_baseURL;
static AFHTTPSessionManager *wkj_manager;

static WKJNetworkStatus wkj_status;
static WKJBuilder *wkj_globalBulider;

+ (void)load
{
    [self reachabilityWorkStatus];
}

#pragma mark - Interface Getter

+ (WKJBuilderCreate)builder
{
    __weak typeof(self) weakSelf = self;
    return ^(NSString *url) {
        WKJBuilder *builder = [WKJBuilder defaultBuilder];
        builder.manager = [weakSelf defaultManager];
        builder.wkj_fullURL = [weakSelf getFullURLPath:url];
        return builder;
    };
}

+ (WKJBuilderCreate)global
{
    __weak typeof(self) weakSelf = self;
    return ^(NSString *url) {
        [weakSelf globalBuilder].wkj_fullURL = [weakSelf getFullURLPath:url];
        return wkj_globalBulider;
    };
}

+ (WKJNetworkStatus)currentNetworkStatus
{
    return wkj_status;
}

+ (void)registBaseURL:(NSString *)baseURL
{
    @synchronized (self) {
        wkj_baseURL = baseURL;
    }
}

+ (void)registResponseBlock:(WKJCustomerResponse)customResponse
{
    [self globalBuilder].responseBlock = customResponse;
}

+ (void)suspendAllRequest
{
    @synchronized (self) {
        [wkj_manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task suspend];
            WKJLog(@"已暂停全部请求");
        }];
    }
}

+ (void)suspendRequest:(NSString *)url
{
    if (!url.length) return;
    @synchronized (self) {
        [wkj_manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *absURL = task.currentRequest.URL.path;
            if ([absURL hasSuffix:url]) {
                [task suspend];
                *stop = YES;
                WKJLog(@"已暂停请求：%@",url);
            }
        }];
    }
}

+ (void)resumeAllRequest
{
    @synchronized (self) {
        [wkj_manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task resume];
        }];
    }
}

+ (void)resumeRequest:(NSString *)url
{
    if (!url.length) return;
    @synchronized (self) {
        [wkj_manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *absURL = task.currentRequest.URL.path;
            if ([absURL hasSuffix:url]) {
                [task resume];
                *stop = YES;
            }
        }];
    }
}

+ (void)cancelAllRequest
{
    @synchronized (self) {
        [wkj_manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
            WKJLog(@"已取消全部请求");
        }];
    }
}

+ (void)cancelRequest:(NSString *)url
{
    if (!url.length) return;
    @synchronized (self) {
        [wkj_manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = task.currentRequest.URL.path;
            if ([path hasSuffix:url]) {
                [task cancel];
                *stop = YES;
                WKJLog(@"已取消请求：%@",url);
            }
        }];
    }
}

#pragma mark - Private

+ (WKJBuilder *)globalBuilder
{
    if (!wkj_globalBulider) {
        wkj_globalBulider = [WKJBuilder defaultBuilder];
        wkj_globalBulider.manager = [self defaultManager];
    }
    return wkj_globalBulider;
}

+ (AFHTTPSessionManager *)defaultManager
{
    if (!wkj_manager) {
        wkj_manager = [AFHTTPSessionManager manager];
        wkj_manager.operationQueue.maxConcurrentOperationCount = 10;
        wkj_manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    }
    return wkj_manager;
}

+ (NSString *)getFullURLPath:(NSString *)subURL
{
    if (!subURL.length) return nil;
    
    NSMutableString *fullURL = [[NSMutableString alloc] init];
    
    if ([subURL hasPrefix:@"http"]) {
        return [self encodeURLString:subURL];
    }
    
    if (wkj_baseURL.length) {
        [fullURL appendString:wkj_baseURL];
    }
    
    if (![wkj_baseURL hasSuffix:@"/"]) {
        [fullURL appendString:@"/"];
    }
    
    if ([subURL hasPrefix:@"/"]) {
        subURL = [subURL substringFromIndex:1];
    }
    
    [fullURL appendString:subURL];
    
    return [self encodeURLString:fullURL];
}

+ (NSString *)encodeURLString:(NSString *)URLString
{
    if (!URLString.length) return nil;
    
    NSCharacterSet *allowSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    return [URLString stringByAddingPercentEncodingWithAllowedCharacters:allowSet];
}

+ (void)reachabilityWorkStatus
{
    AFNetworkReachabilityManager *rm = [AFNetworkReachabilityManager sharedManager];
    [rm startMonitoring];
    
    [rm setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                wkj_status = WKJNetworkStatusUnknown;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                wkj_status = WKJNetworkStatusNotReachable;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                wkj_status = WKJNetworkStatusWiFi;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                wkj_status = WKJNetworkStatusWWAN;
                break;
        }
    }];
}

@end

