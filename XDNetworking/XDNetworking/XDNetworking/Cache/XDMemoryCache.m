//
//  XDMemoryCache.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XDMemoryCache.h"

static NSCache *shareCache;

/**
 *  到时可以拓展内存缓存策略
 */
@implementation XDMemoryCache

+ (NSCache *)shareCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareCache == nil) shareCache = [[NSCache alloc] init];
    });
    return shareCache;
}

+ (void)writeData:(id)data forKey:(NSString *)key {
    NSCache *cache = [XDMemoryCache shareCache];
    
    [cache setObject:data forKey:key];
    
}

+ (id)readDataWithKey:(NSString *)key {
    id data = nil;
    
    NSCache *cache = [XDMemoryCache shareCache];
    
    data = [cache objectForKey:key];
    
    return data;
}

@end
