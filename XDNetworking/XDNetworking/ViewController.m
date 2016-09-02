//
//  ViewController.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "ViewController.h"
#import "XDNetworking.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        NSLog(@"size is %lu",(unsigned long)[XDNetworking totalCacheSize]);
    
    NSLog(@"%@",[self md5:@"http://115.29.228.168:9191/workmap_dianAn/command/command.do?opCommand=userAction+1122"]);

    
    
}
- (IBAction)sendRequest:(UIButton *)sender {

    [XDNetworking postWithUrl:@"http://115.29.228.168:9191/workmap_dianAn/command/command.do?opCommand=userAction"
               refreshRequest:NO
                        cache:YES params:@{@"action":@"getDataList",
                                                                                                                                     @"project_id":@"561113"
                                                                                                                                     } progressBlock:^(int64_t bytesRead, int64_t totalBytes) {
                                                                                                                                         
                                                                                                                                     } successBlock:^(id response) {
                                                                                                                                         //NSLog(@"response is %@",response[@"other"]);
                                                                                                                                         
                                                                                                                                             NSLog(@"sss size is %lu",(unsigned long)[XDNetworking totalCacheSize]);
                                                                                                                                     } failBlock:^(NSError *error) {
                                                                                                                                         
                                                                                                                                     }];

}


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
