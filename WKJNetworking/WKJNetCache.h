//
//  WKJNetCache.h
//  WKJNetWorking
//
//  Created by 王恺靖 on 2018/3/14.
//  Copyright © 2018年 WKJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKJNetCache : NSObject

+ (void)setHttpCache:(id)data URL:(NSString *)URL params:(NSDictionary *)params;

+ (id)cacheForURL:(NSString *)URL params:(NSDictionary *)params;

+ (NSInteger)getHttpCacheSize;

+ (void)clearHttpCache;

+ (NSString *)getMD5String:(NSString *)string;

@end
