//
//  XD_LRUManager.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/8/27.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XD_LRUManager.h"
#import "XDNetworkingMacro.h"

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
        if (XD_NSUSERDEFAULT_GETTER(XD_LRUManagerName)) {
            operationQueue = [NSMutableArray arrayWithArray:(NSArray *)XD_NSUSERDEFAULT_GETTER(XD_LRUManagerName)];
        }else {
                operationQueue = [NSMutableArray array];   
        }
    });
    return manager;
}
- (void)addFileNode:(NSString *)filename {
    NSArray *array = [operationQueue copy];
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:filename]) {
            [operationQueue removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    [operationQueue addObject:filename];
    XD_NSUSERDEFAULT_SETTER([operationQueue copy], XD_LRUManagerName);
}

- (void)refreshIndexOfFileNode:(NSString *)filename {
    [self addFileNode:filename];
}

- (NSString *)removeLRUFileNode {
    NSString *removeFile = nil;
    if (operationQueue.count > 0) {
        removeFile = [operationQueue firstObject];
        [operationQueue removeObjectAtIndex:0];
        XD_NSUSERDEFAULT_SETTER([operationQueue copy], XD_LRUManagerName);
    }
    return removeFile;

}

- (NSArray *)currentQueue {
    return [operationQueue copy];
}

@end
