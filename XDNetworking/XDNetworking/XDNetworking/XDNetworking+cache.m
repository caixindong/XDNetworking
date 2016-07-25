//
//  XDNetworking+cache.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XDNetworking+cache.h"
#import "XDMemoryCache.h"
#import "XDDistCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation XDNetworking (cache)

+ (void)cacheResponseObject:(id)responseObject
                 requestUrl:(NSString *)requestUrl
                     params:(NSDictionary *)params {
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@+%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    NSData *data = nil;
    NSError *error = nil;
    if ([responseObject isKindOfClass:[NSData class]]) {
        data = responseObject;
    }else if ([responseObject isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    if (data && hash && error == nil) {
        //缓存到内存中
        [XDMemoryCache writeData:responseObject forKey:hash];
        
        //缓存到磁盘中
        //磁盘路径
        NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"XDNetworking"] stringByAppendingPathComponent:@"networkCache"];
        [XDDistCache writeData:data toDir:directoryPath filename:hash];
    }
    
}

+ (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl
                                    params:(NSDictionary *)params {
    id cacheData = nil;
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@+%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
     NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"XDNetworking"] stringByAppendingPathComponent:@"networkCache"];
    
    //先从内存中查找
    cacheData = [XDMemoryCache readDataWithKey:hash];
    
    if (!cacheData) {
        cacheData = [XDDistCache readDataFromDir:directoryPath filename:hash];
    }
    
    return cacheData;
}

+ (void)storeDownloadData:(NSData *)data
               requestUrl:(NSString *)requestUrl {
    NSString *fileName = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    
    if (requestUrl) {
        strArray = [requestUrl componentsSeparatedByString:@"."];
        if (strArray.count > 0) {
            type = strArray[strArray.count - 1];
        }
    }
    
    if (type) {
        fileName = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        fileName = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
    NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"XDNetworking"] stringByAppendingPathComponent:@"download"];
    [XDDistCache writeData:data toDir:directoryPath filename:fileName];

}

+ (NSURL *)getDownloadDataFromCacheWithRequestUrl:(NSString *)requestUrl {
    NSData *data = nil;
    NSString *fileName = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    NSURL *fileUrl = nil;
    
    if (requestUrl) {
        strArray = [requestUrl componentsSeparatedByString:@"."];
        if (strArray.count > 0) {
            type = strArray[strArray.count - 1];
        }
    }
    
    if (type) {
        fileName = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        fileName = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
      NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"XDNetworking"] stringByAppendingPathComponent:@"download"];
    
    data = [XDDistCache readDataFromDir:directoryPath filename:fileName];
    
    if (data) {
        NSString *path = [directoryPath stringByAppendingPathComponent:fileName];
        fileUrl = [NSURL fileURLWithPath:path];
    }
    
    return fileUrl;
}

#pragma mark - 散列值
+ (NSString *)md5:(NSString *)string {
    if (string == nil || string.length == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH],i;
    
    CC_MD5([string UTF8String],(int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding],digest);
    
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x",(int)(digest[i])];
    }
    
    return [ms copy];
}

@end
