//
//  AppDelegate.m
//  WKJNetworkingDemo
//
//  Created by 王恺靖 on 2018/6/6.
//  Copyright © 2018年 wkj. All rights reserved.
//

#import "AppDelegate.h"
#import "WKJNetworking.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupNetworking];
    return YES;
}

/**
 * 该方法可以单独封装至某个类
 */
- (void)setupNetworking
{
    /** 设置公共请求的参数 */
    WKJNetworking.global(nil).header(@{@"Test-Key":@"123"}).timeout(10);
    
    /** 注册公共请求地址，可以在APPDelegate中使用 */
    [WKJNetworking registBaseURL:@"http://web.juhe.cn:8080/finance/exchange"];
    
    /**
     * 这里可以根据公司接口的数据格式做自定义回调配置，可以在APPDelegate中使用；
     * 之后只要使用global构建的请求都会使用一下配置的回调（注：该方法仅支持global构建的请求）
     *
     * 如该网站数据格式统一为：{"resultcode":"200",
     *                      "reason":"SUCCESSED!",
     *                      "result":xxxxxxx}
     * 则可以将回调内容更改如下：
     */
    [WKJNetworking registResponseBlock:^(id respones, NSError *error, RequestSuccess rs, RequestFail rf) {
        // 处理网络错误回调
        if (error.code == -1009) {
            NSError *error = [NSError errorWithDomain:@"无网络连接" code:-1009 userInfo:nil];
            rf(error);
            return;
        }
        // 处理业务逻辑回调
        if ([respones[@"resultcode"] intValue] == 200) {
            rs(respones[@"result"]);
        }
        else {
            NSError *error = [NSError errorWithDomain:respones[@"reason"]
                                                 code:[respones[@"resultcode"] intValue]
                                             userInfo:nil];
            rf(error);
        }
    }];
}

@end
