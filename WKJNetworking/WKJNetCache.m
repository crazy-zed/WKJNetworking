//
//  WKJNetCache.m
//  WKJNetWorking
//
//  Created by 王恺靖 on 2018/3/14.
//  Copyright © 2018年 WKJ. All rights reserved.
//

#import "WKJNetCache.h"
#import "WKJNetworking.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation WKJNetCache

+ (void)setHttpCache:(id)data URL:(NSString *)URL
{
    if (![data isKindOfClass:[NSDictionary class]]) return;
    
    NSString *dirPath = [self getCachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if (![fm fileExistsAtPath:dirPath]) {
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error) {
        WKJLog(@"create cache directory error:%@",error);
        return;
    }
    
    NSString *path = [dirPath stringByAppendingPathComponent:[self getMD5String:URL]];
    BOOL isOk = [data writeToFile:path atomically:YES];
    
    if (isOk) {
        WKJLog(@"save cache at:%@",dirPath);
    }
    else {
        WKJLog(@"save cache error");
    }
}

+ (id)cacheForURL:(NSString *)URL
{
    NSString *dirPath = [self getCachePath];
    NSString *path = [dirPath stringByAppendingPathComponent:[self getMD5String:URL]];
    
    NSDictionary *cache = [NSDictionary dictionaryWithContentsOfFile:path];
    return cache;
}

+ (NSInteger)getHttpCacheSize
{
    NSString *dirPath = [self getCachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:dirPath]) return 0;
    
    NSError *error = nil;
    NSArray *array = [fm contentsOfDirectoryAtPath:dirPath error:&error];
    if (error) {
        WKJLog(@"get cache error:%@",error);
        return 0;
    }
    
    NSInteger size = 0;
    for (NSString *subPath in array) {
        NSString *path = [dirPath stringByAppendingPathComponent:subPath];
        NSDictionary *dict = [fm attributesOfItemAtPath:path error:&error];
        if (!error) {
            size += [dict[NSFileSize] integerValue];
        }
    }
    
    return size;
}

+ (void)clearHttpCache
{
    NSString *dirPath = [self getCachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:dirPath]) return;
    
    NSError *error = nil;
    [fm removeItemAtPath:dirPath error:&error];
    
    if (error) {
        WKJLog(@"clear cache error:%@",error);
    }
}

#pragma mark - Private

+ (NSString *)getCachePath
{
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    return [dirPath stringByAppendingPathComponent:@"Response"];
}

+ (NSString *)getMD5String:(NSString *)string
{
    const char *cString = [string UTF8String];
    unsigned char md5[32];
    
    CC_MD5(cString, (CC_LONG)strlen(cString), md5);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x",md5[i]];
    }
    
    return result;
}


+ (NSString *)cacheKeyWithURL:(NSString *)URL params:(NSDictionary *)params
{
    if(!params) return URL;
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *paramsStr = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    // 将URL与转换好的参数字符串拼接在一起,成为最终存储的KEY值
    NSString *cacheKey = [URL stringByAppendingString:paramsStr];
    
    return cacheKey;
}

@end
