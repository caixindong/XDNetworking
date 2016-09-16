//
//  XDCacheManager.h
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/9/2.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XDCacheManager : NSObject


/**
 *  默认的磁盘空间是40MB，缓存有效期是7天
 *
 *  @return 
 */
+ (XDCacheManager *)shareManager;

/**
 *  设置缓存时间和缓存的磁盘空间
 *
 *  @param time     缓存时间
 *  @param capacity 磁盘空间
 */
- (void)setCacheTime:(NSTimeInterval) time diskCapacity:(NSUInteger) capacity;

/**
 *  缓存响应数据
 *
 *  @param responseObject 响应数据
 *  @param requestUrl     请求url
 *  @param params         请求参数
 */
- (void)cacheResponseObject:(id)responseObject requestUrl:(NSString *)requestUrl params:(NSDictionary *)params;

/**
 *  获取响应数据
 *
 *  @param requestUrl 请求url
 *  @param params     请求参数
 *
 *  @return 响应数据
 */
- (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl params:(NSDictionary *)params;

/**
 *  存储下载文件
 *
 *  @param data       文件数据
 *  @param requestUrl 请求url
 *
 *  @return
 */
- (void)storeDownloadData:(NSData *)data
               requestUrl:(NSString *)requestUrl;

/**
 *  获取磁盘中的下载文件
 *
 *  @param requestUrl 请求url
 *
 *  @return 文件本地存储路径
 */
- (NSURL *)getDownloadDataFromCacheWithRequestUrl:(NSString *)requestUrl;

/**
 *  获取缓存目录路径
 *
 *  @return 缓存目录路径
 */
- (NSString *)getCacheDiretoryPath;

/**
 *  获取下载目录路径
 *
 *  @return 下载目录路径
 */
- (NSString *)getDownDirectoryPath;

/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
- (NSUInteger)totalCacheSize;

/**
 *  清除所有缓存
 */
- (void)clearTotalCache;

/**
 *  清除最近最少使用的缓存，用LRU算法实现
 */
- (void)clearLRUCache;

/**
 *  获取所有下载数据大小
 *
 *  @return 下载数据大小
 */
- (NSUInteger)totalDownloadDataSize;

/**
 *  清除下载数据
 */
- (void)clearDownloadData;

@end
