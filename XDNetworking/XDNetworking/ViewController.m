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
    
    

    
    
}
- (IBAction)sendRequest:(UIButton *)sender {

    [XDNetworking getWithUrl:@"http://115.29.228.168:9191/workmap_dianAn/command/command.do?opCommand=userAction"
               refreshRequest:NO
                        cache:YES
                      params:@{@"action":@"getDataList",@"project_id":@"561113"}
               progressBlock:^(int64_t bytesRead, int64_t totalBytes) {
                                                                                                                                         
               }
                successBlock:^(id response) {
                
                }
                   failBlock:^(NSError *error) {
                                                                                                                                         
    }];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




@end


