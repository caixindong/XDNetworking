//
//  NSURLRequest+decide.h
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/8/9.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURLRequest (decide)

/**
 *  判断是否是同一个请求（依据是请求url和参数是否相同）
 *
 *  @param request
 *
 *  @return
 */
- (BOOL)isTheSameRequest:(NSURLRequest *)request;

@end
