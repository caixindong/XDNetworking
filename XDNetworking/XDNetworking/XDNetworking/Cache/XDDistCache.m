//
//  XDDistCache.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XDDistCache.h"

/**
 *  到时可以拓展磁盘缓存策略
 */
@implementation XDDistCache

+ (void)writeData:(id)data
            toDir:(NSString *)directory
         filename:(NSString *)filename{
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error) {
        NSLog(@"createDirectory error is %@",error.localizedDescription);
        return;
    }
    
    NSString *filePath = [directory stringByAppendingPathComponent:filename];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
    
}

+ (id)readDataFromDir:(NSString *)directory
             filename:(NSString *)filename {
    NSData *data = nil;
    
    NSString *filePath = [directory stringByAppendingPathComponent:filename];
    
    data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    return data;
}

@end
