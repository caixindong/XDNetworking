//
//  XD_LRUManager.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/8/27.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XD_LRUManager.h"

static XD_LRUManager *manager = nil;

static NSMutableArray *operationQueue = nil;

static NSString *const XD_LRUManagerName = @"XD_LRUManagerName";

@interface XD_LRUManager()

@end

@implementation XD_LRUManager

+ (XD_LRUManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XD_LRUManager alloc] init];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:XD_LRUManagerName]) {
            operationQueue = [NSMutableArray arrayWithArray:(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:XD_LRUManagerName]];
        }else {
                operationQueue = [NSMutableArray array];   
        }
    });
    return manager;
}
- (void)addFileNode:(NSString *)filename {
    NSArray *array = [operationQueue copy];
    
    //优化遍历
    NSArray *reverseArray = [[array reverseObjectEnumerator] allObjects];
    
    [reverseArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"fileName"] isEqualToString:filename]) {
            [operationQueue removeObjectAtIndex:idx];
            *stop = YES;
        }

    }];
    
    NSDate *date = [NSDate date];
    
    NSDictionary *newDic = @{@"fileName":filename,@"date":date};
    
    [operationQueue addObject:newDic];
    
    [[NSUserDefaults standardUserDefaults] setObject:[operationQueue copy] forKey:XD_LRUManagerName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshIndexOfFileNode:(NSString *)filename {
    [self addFileNode:filename];
}

- (NSArray *)removeLRUFileNodeWithCacheTime:(NSTimeInterval)time {
    NSMutableArray *result = [NSMutableArray array];
    
    if (operationQueue.count > 0) {
        
        NSArray *tmpArray = [operationQueue copy];
        
        [tmpArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDate *date = obj[@"date"];
            NSDate *newDate = [date dateByAddingTimeInterval:time];
            if ([[NSDate date] compare:newDate] == NSOrderedDescending) {
                [result addObject:obj[@"fileName"]];
                [operationQueue removeObjectAtIndex:idx];
            }
        }];
        
        if (result.count == 0) {
            NSString *removeFileName = [operationQueue firstObject][@"fileName"];
            [result addObject:removeFileName];
            [operationQueue removeObjectAtIndex:0];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[operationQueue copy] forKey:XD_LRUManagerName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [result copy];

}

- (NSArray *)currentQueue {
    return [operationQueue copy];
}

@end
