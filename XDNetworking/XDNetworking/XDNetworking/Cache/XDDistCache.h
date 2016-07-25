//
//  XDDistCache.h
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XDDistCache : NSObject

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

@end
