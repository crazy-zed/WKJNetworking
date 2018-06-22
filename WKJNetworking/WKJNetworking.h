//
//  WKJNetWorking.h
//  WKJNetWorking
//
//  Created by 王恺靖 on 2018/3/9.
//  Copyright © 2018年 WKJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKJNetCache.h"

/* Log定义 */
#ifdef DEBUG

#define WKJLog(fmt, ...) NSLog((@"[Line %d] %s \n" fmt), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#else

#define WKJLog(fmt, ...)

#endif

@class WKJNetworking, WKJBuilder, WKJRequest, WKJResponse, WKJError;

typedef NS_ENUM(NSInteger, WKJNetworkStatus) {
    WKJNetworkStatusUnknown        = -1, //未知网络
    WKJNetworkStatusNotReachable   = 0,  //网络无连接
    WKJNetworkStatusWWAN           = 1,  //2，3，4G网络
    WKJNetworkStatusWiFi           = 2,  //WIFI网络
};

typedef NS_ENUM(NSUInteger, WKJMediaType) {
    WKJMediaTypeJSON = 0,   // "application/json"
    WKJMediaTypeXML  = 1,   // "application/xml"
    WKJMediaTypeFORM = 2,   // "application/x-www-form-urlencoded"
    WKJMediaTypeData = 3    // "application/form-data"
};

typedef void (^RequestProgress)(int64_t completed, int64_t total);
typedef void (^RequestSuccess)(id respones);
typedef void (^RequestFail)(NSError *error);

// WKJNetworking对象所属
typedef WKJBuilder *(^WKJBuilderCreate)(NSString *url);
typedef void (^WKJCustomerResponse)(id respones, NSError *error, RequestSuccess rs, RequestFail rf);

// WKJBuilder对象所属
typedef WKJBuilder *(^WKJTimeout)(NSTimeInterval sec);
typedef WKJBuilder *(^WKJRequestType)(WKJMediaType requestType);
typedef WKJBuilder *(^WKJResponseType)(WKJMediaType responesType);
typedef WKJBuilder *(^WKJHeader)(NSDictionary *header);
typedef WKJBuilder *(^WKJCached)(BOOL shouldCache);

typedef WKJRequest *(^WKJRequestStart)(void);

// WKJRequest对象所属
typedef WKJResponse *(^WKJGet)(NSDictionary *params);
typedef WKJResponse *(^WKJPost)(NSDictionary *params);
typedef WKJResponse *(^WKJUploadImages)(NSDictionary *params, NSArray<UIImage *> *images, NSString *imagesKey);
typedef WKJResponse *(^WKJUploadFile)(NSString *path, NSString *fileKey);
typedef WKJResponse *(^WKJDownloadFile)(NSString *savePath);

// WKJResponse对象所属
typedef WKJResponse *(^WKJSuccess)(RequestSuccess rs);
typedef WKJResponse *(^WKJFail)(RequestFail rf);
typedef WKJResponse *(^WKJProgress)(RequestProgress rp);

#pragma mark - 请求入口及相关请求状态操作

@interface WKJNetworking : NSObject

/** 创建请求构建对象，该构建对象每次请求都会创建新对象，针对单独请求构建方式。参数（NSString *url） */
+ (WKJBuilderCreate)builder;

/** 创建请求构建对象，该构建对象只会创建一次，针对全局请求构建方式，设置一次全局使用。参数（NSString *url）*/
+ (WKJBuilderCreate)global;

/** 获取当前网络状态 */
+ (WKJNetworkStatus)currentNetworkStatus;

/** 注册基有URL，针对global构建对象使用（虽然也可以使用builder，但不建议）*/
+ (void)registBaseURL:(NSString *)baseURL;

/** 注册自定义网络响应回调，可根据原有相应数据在做自定义处理
 *  customResponse参数：
 *  id respones（原始响应数据）
 *  NSError *error（请求错误）
 *  RequestSuccess rs（成功回调）
 *  RequestFail rf（失败回调）
 */
+ (void)registResponseBlock:(WKJCustomerResponse)customResponse;

/** 暂停所有请求 */
+ (void)suspendAllRequest;

/** 暂停某个URL请求 */
+ (void)suspendRequest:(NSString *)url;

/** 恢复所有请求 */
+ (void)resumeAllRequest;

/** 恢复某个URL请求 */
+ (void)resumeRequest:(NSString *)url;

/** 取消所有请求 */
+ (void)cancelAllRequest;

/** 取消某个URL请求 */
+ (void)cancelRequest:(NSString *)url;

@end

#pragma mark - 请求相关配置入口

@interface WKJBuilder : NSObject

/** 设置请求超时时间，参数为“NSTimeInterval”（默认15s） */
@property (nonatomic, copy, readonly) WKJTimeout timeout;

/** 设置请求参数类型（只对POST请求有效），参数为“WKJMediaType”（默认WKJMediaTypeFORM） */
@property (nonatomic, copy, readonly) WKJRequestType requestType;

/** 设置请求响应内容类型，参数为“WKJMediaType”（默认WKJMediaTypeJSON） */
@property (nonatomic, copy, readonly) WKJResponseType responesType;

/** 设置请求头，参数为“NSDictionary” */
@property (nonatomic, copy, readonly) WKJHeader header;

/** 设置是否缓存，参数为“BOOL”（默认为NO）*/
@property (nonatomic, copy, readonly) WKJCached cache;

/** 开始请求 */
@property (nonatomic, copy, readonly) WKJRequestStart request;

@end

#pragma mark - 请求具体方法入口

@interface WKJRequest : NSObject

/** 发起GET请求，参数为“NSDictionary” */
@property (nonatomic, copy, readonly) WKJGet get;

/** 发起POST请求，参数为“NSDictionary” */
@property (nonatomic, copy, readonly) WKJPost post;

/** 发起上传图片请求，参数为“NSDictionary，NSArray<UIImage *>，NSString” */
@property (nonatomic, copy, readonly) WKJUploadImages uploadImages;

/** 发起上传文件请求，参数为“NSString, NSString” */
@property (nonatomic, copy, readonly) WKJUploadFile uploadFile;

/** 发起下载文件请求，参数为“NSString” */
@property (nonatomic, copy, readonly) WKJDownloadFile downloadFile;

@end

#pragma mark - 请求响应操作入口

@interface WKJResponse : NSObject

/** 请求进度，参数为“RequestProgress回调” */
@property (nonatomic, copy, readonly) WKJProgress progress;

/** 请求成功，参数为“RequestSuccess回调” */
@property (nonatomic, copy, readonly) WKJSuccess success;

/** 请求失败，参数为“RequestFail回调” */
@property (nonatomic, copy, readonly) WKJFail fail;

/** 请求头信息 */
@property (nonatomic, strong, readonly) NSDictionary *header;

@end

