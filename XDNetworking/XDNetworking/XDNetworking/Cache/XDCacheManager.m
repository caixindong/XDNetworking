//
//  XDCacheManager.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/9/2.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XDCacheManager.h"
#import "XDMemoryCache.h"
#import "XDDistCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "XD_LRUManager.h"
#import "XDNetworkingMacro.h"

static NSString *const cacheDirKey = @"cacheDirKey";

static NSString *const downloadDirKey = @"downloadDirKey";

static NSUInteger diskCapacity = 40 * 1024 * 1024;

static NSTimeInterval cacheTime = 7 * 24 * 60 * 60;

@implementation XDCacheManager

+ (XDCacheManager *)shareManager {
    static XDCacheManager *_XDCacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _XDCacheManager = [[XDCacheManager alloc] init];
    });
    return _XDCacheManager;
}

- (void)setCacheTime:(NSTimeInterval)time diskCapacity:(NSUInteger)capacity {
    diskCapacity = capacity;
    cacheTime = time;
}

- (void)cacheResponseObject:(id)responseObject
                 requestUrl:(NSString *)requestUrl
                     params:(NSDictionary *)params {
    assert(responseObject);
    
    assert(requestUrl);
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@-%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    NSData *data = nil;
    NSError *error = nil;
    if ([responseObject isKindOfClass:[NSData class]]) {
        data = responseObject;
    }else if ([responseObject isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    if (error == nil) {
        //缓存到内存中
        [XDMemoryCache writeData:responseObject forKey:hash];
        
        //缓存到磁盘中
        //磁盘路径
        NSString *directoryPath = nil;
        directoryPath = XD_NSUSERDEFAULT_GETTER(cacheDirKey);
        if (!directoryPath) {
            directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"XDNetworking"] stringByAppendingPathComponent:@"networkCache"];
            XD_NSUSERDEFAULT_SETTER(directoryPath,cacheDirKey);
        }
        [XDDistCache writeData:data toDir:directoryPath filename:hash];
        
        [[XD_LRUManager shareManager] addFileNode:hash];
    }
    
}

- (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl
                                    params:(NSDictionary *)params {
    assert(requestUrl);
    
    id cacheData = nil;
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    //先从内存中查找
    cacheData = [XDMemoryCache readDataWithKey:hash];
    
    if (!cacheData) {
        NSString *directoryPath = XD_NSUSERDEFAULT_GETTER(cacheDirKey);
        
        if (directoryPath) {
            cacheData = [XDDistCache readDataFromDir:directoryPath filename:hash];
            
            if (cacheData) [[XD_LRUManager shareManager] refreshIndexOfFileNode:hash];
        }
    }
    
    return cacheData;
}

- (void)storeDownloadData:(NSData *)data
               requestUrl:(NSString *)requestUrl {
    assert(data);
    
    assert(requestUrl);
    
    NSString *fileName = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    
    strArray = [requestUrl componentsSeparatedByString:@"."];
    if (strArray.count > 0) {
        type = strArray[strArray.count - 1];
    }
    
    if (type) {
        fileName = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        fileName = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
    NSString *directoryPath = nil;
    directoryPath = XD_NSUSERDEFAULT_GETTER(downloadDirKey);
    if (!directoryPath) {
        directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"XDNetworking"] stringByAppendingPathComponent:@"download"];
        
        XD_NSUSERDEFAULT_SETTER(directoryPath, downloadDirKey);
    }
    
    
    [XDDistCache writeData:data toDir:directoryPath filename:fileName];
    
}

- (NSURL *)getDownloadDataFromCacheWithRequestUrl:(NSString *)requestUrl {
    assert(requestUrl);
    
    NSData *data = nil;
    NSString *fileName = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    NSURL *fileUrl = nil;
    
    
    strArray = [requestUrl componentsSeparatedByString:@"."];
    if (strArray.count > 0) {
        type = strArray[strArray.count - 1];
    }
    
    if (type) {
        fileName = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        fileName = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
    
    NSString *directoryPath = XD_NSUSERDEFAULT_GETTER(downloadDirKey);
    
    if (directoryPath) data = [XDDistCache readDataFromDir:directoryPath filename:fileName];
    
    if (data) {
        NSString *path = [directoryPath stringByAppendingPathComponent:fileName];
        fileUrl = [NSURL fileURLWithPath:path];
    }
    
    return fileUrl;
}

- (NSUInteger)totalCacheSize {
    NSString *diretoryPath = XD_NSUSERDEFAULT_GETTER(cacheDirKey);
    
    return [XDDistCache dataSizeInDir:diretoryPath];
}

- (NSUInteger)totalDownloadDataSize {
    NSString *diretoryPath = XD_NSUSERDEFAULT_GETTER(downloadDirKey);
    
    return [XDDistCache dataSizeInDir:diretoryPath];
}

- (void)clearDownloadData {
    NSString *diretoryPath = XD_NSUSERDEFAULT_GETTER(downloadDirKey);
    
    [XDDistCache clearDataIinDir:diretoryPath];
}

- (NSString *)getDownDirectoryPath {
    NSString *diretoryPath = XD_NSUSERDEFAULT_GETTER(downloadDirKey);
    return diretoryPath;
}

- (NSString *)getCacheDiretoryPath {
    NSString *diretoryPath = XD_NSUSERDEFAULT_GETTER(cacheDirKey);
    return diretoryPath;
}

- (void)clearTotalCache {
    NSString *directoryPath = XD_NSUSERDEFAULT_GETTER(cacheDirKey);
    
    [XDDistCache clearDataIinDir:directoryPath];
}

- (void)clearLRUCache {
    if ([self totalCacheSize] > diskCapacity) {
        NSArray *deleteFiles = [[XD_LRUManager shareManager] removeLRUFileNodeWithCacheTime:cacheTime];
        NSString *directoryPath = XD_NSUSERDEFAULT_GETTER(cacheDirKey);
        if (directoryPath && deleteFiles.count > 0) {
            [deleteFiles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *filePath = [directoryPath stringByAppendingPathComponent:obj];
                [XDDistCache deleteCache:filePath];
            }];
            
        }
    }
}

#pragma mark - 散列值
- (NSString *)md5:(NSString *)string {
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
