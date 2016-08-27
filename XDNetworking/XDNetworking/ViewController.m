//
//  ViewController.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "ViewController.h"
#import "XDNetworking+cache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        NSLog(@"size is %llu",[XDNetworking totalCacheSize]);

    
    
}
- (IBAction)sendRequest:(UIButton *)sender {

    [XDNetworking postWithUrl:@"http://115.29.228.168:9191/workmap_dianAn/command/command.do?opCommand=userAction"
               refreshRequest:NO
                        cache:YES params:@{@"action":@"getDataList",
                                                                                                                                     @"project_id":@"561113"
                                                                                                                                     } progressBlock:^(int64_t bytesRead, int64_t totalBytes) {
                                                                                                                                         
                                                                                                                                     } successBlock:^(id response) {
                                                                                                                                         //NSLog(@"response is %@",response[@"other"]);
                                                                                                                                         
                                                                                                                                             NSLog(@"sss size is %llu",[XDNetworking totalCacheSize]);
                                                                                                                                     } failBlock:^(NSError *error) {
                                                                                                                                         
                                                                                                                                     }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
