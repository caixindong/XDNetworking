//
//  XDDiskCache.h
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/9/15.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XDDiskCache : NSObject

/**
 *  将数据写入磁盘
 *
 *  @param data      数据
 *  @param directory 目录
 *  @param filename  文件名
 */
+ (void)writeData:(id)data
            toDir:(NSString *)directory
         filename:(NSString *)filename;

/**
 *  从磁盘读取数据
 *
 *  @param directory 目录
 *  @param filename  文件名
 *
 *  @return 数据
 */
+ (id)readDataFromDir:(NSString *)directory
             filename:(NSString *)filename;

/**
 *  获取目录中文件总大小
 *
 *  @param directory 目录名
 *
 *  @return 文件总大小
 */
+ (NSUInteger)dataSizeInDir:(NSString *)directory;

/**
 *  清理目录中的文件
 *
 *  @param directory 目录名
 */
+ (void)clearDataIinDir:(NSString *)directory;

/**
 *  删除某文件
 *
 *  @param fileUrl 文件路径
 */
+ (void)deleteCache:(NSString *)fileUrl;

@end
