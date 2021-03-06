//
//  XDNetworking.m
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/7/25.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "XDNetworking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "XDNetworking+requestManager.h"
#import "XDCacheManager.h"

#define XD_ERROR_IMFORMATION @"网络出现错误，请检查网络连接"

#define XD_ERROR [NSError errorWithDomain:@"com.caixindong.XDNetworking.ErrorDomain" code:-999 userInfo:@{ NSLocalizedDescriptionKey:XD_ERROR_IMFORMATION}]

static NSMutableArray   *requestTasksPool;

static NSDictionary     *headers;

static XDNetworkStatus  networkStatus;

static NSTimeInterval   requestTimeout = 20.f;

@implementation XDNetworking

#pragma mark - manager
+ (AFHTTPSessionManager *)manager {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //默认解析模式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //配置请求序列化
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    
    [serializer setRemovesKeysWithNullValues:YES];
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    manager.requestSerializer.timeoutInterval = requestTimeout;
    
    for (NSString *key in headers.allKeys) {
        if (headers[key] != nil) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    //配置响应序列化
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*",
                                                                              @"application/octet-stream",
                                                                              @"application/zip"]];
    
    [self checkNetworkStatus];
    
    //每次网络请求的时候，检查此时磁盘中的缓存大小，阈值默认是40MB，如果超过阈值，则清理LRU缓存,同时也会清理过期缓存，缓存默认SSL是7天，磁盘缓存的大小和SSL的设置可以通过该方法[XDCacheManager shareManager] setCacheTime: diskCapacity:]设置
    [[XDCacheManager shareManager] clearLRUCache];
    
    return manager;
}

#pragma mark - 检查网络
+ (void)checkNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus = XDNetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusUnknown:
                networkStatus = XDNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus = XDNetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus = XDNetworkStatusReachableViaWiFi;
                break;
            default:
                networkStatus = XDNetworkStatusUnknown;
                break;
        }
        
    }];
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTasksPool == nil) requestTasksPool = [NSMutableArray array];
    });
    
    return requestTasksPool;
}

#pragma mark - get
+ (XDURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(XDGetProgress)progressBlock
                    successBlock:(XDResponseSuccessBlock)successBlock
                       failBlock:(XDResponseFailBlock)failBlock {
    //将session拷贝到堆中，block内部才可以获取得到session
    __block XDURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == XDNetworkStatusNotReachable) {
        if (failBlock) failBlock(XD_ERROR);
        return session;
    }
    
    
    id responseObj = [[XDCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (successBlock) successBlock(responseObj);
    }
    
    session = [manager GET:url
                parameters:params
                  progress:^(NSProgress * _Nonnull downloadProgress) {
                      if (progressBlock) progressBlock(downloadProgress.completedUnitCount,
                                                       downloadProgress.totalUnitCount);
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      if (successBlock) successBlock(responseObject);
                      
                      if (cache) [[XDCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                      
                      [[self allTasks] removeObject:session];
    
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) failBlock(error);
                      [[self allTasks] removeObject:session];
                      
                  }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        //取消新请求
        [session cancel];
        return session;
    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        XDURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - post
+ (XDURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                    progressBlock:(XDPostProgress)progressBlock
                     successBlock:(XDResponseSuccessBlock)successBlock
                        failBlock:(XDResponseFailBlock)failBlock {
    __block XDURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == XDNetworkStatusNotReachable) {
        if (failBlock) failBlock(XD_ERROR);
        return session;
    }
    
    id responseObj = [[XDCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (successBlock) successBlock(responseObj);
    }
    
    session = [manager POST:url
                 parameters:params
                   progress:^(NSProgress * _Nonnull uploadProgress) {
                       if (progressBlock) progressBlock(uploadProgress.completedUnitCount,
                                                        uploadProgress.totalUnitCount);
                       
                   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                       if (successBlock) successBlock(responseObject);

                       if (cache) [[XDCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                       
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       if (failBlock) failBlock(error);
                       [[self allTasks] removeObject:session];
                       
                   }];
    
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else {
        XDURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - 文件上传
+ (XDURLSessionTask *)uploadFileWithUrl:(NSString *)url
                               fileData:(NSData *)data
                                   type:(NSString *)type
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeType
                          progressBlock:(XDUploadProgressBlock)progressBlock
                           successBlock:(XDResponseSuccessBlock)successBlock
                              failBlock:(XDResponseFailBlock)failBlock {
    __block XDURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == XDNetworkStatusNotReachable) {
        if (failBlock) failBlock(XD_ERROR);
        return session;
    }
    
    session = [manager POST:url
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      NSString *fileName = nil;
      
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyyMMddHHmmss";
      
      NSString *day = [formatter stringFromDate:[NSDate date]];
      
      fileName = [NSString stringWithFormat:@"%@.%@",day,type];
      
      [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) progressBlock (uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) successBlock(responseObject);
        [[self allTasks] removeObject:session];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) failBlock(error);
        [[self allTasks] removeObject:session];
        
    }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
}

#pragma mark - 多文件上传
+ (NSArray *)uploadMultFileWithUrl:(NSString *)url
                         fileDatas:(NSArray *)datas
                              type:(NSString *)type
                              name:(NSString *)name
                          mimeType:(NSString *)mimeTypes
                     progressBlock:(XDUploadProgressBlock)progressBlock
                      successBlock:(XDMultUploadSuccessBlock)successBlock
                         failBlock:(XDMultUploadFailBlock)failBlock {
    
    if (networkStatus == XDNetworkStatusNotReachable) {
        if (failBlock) failBlock(@[XD_ERROR]);
        return nil;
    }
    
    __block NSMutableArray *sessions = [NSMutableArray array];
    __block NSMutableArray *responses = [NSMutableArray array];
    __block NSMutableArray *failResponse = [NSMutableArray array];
    
    dispatch_group_t uploadGroup = dispatch_group_create();
    
    NSInteger count = datas.count;
    for (int i = 0; i < count; i++) {
        __block XDURLSessionTask *session = nil;
        
        dispatch_group_enter(uploadGroup);
        
        session = [self uploadFileWithUrl:url
                                 fileData:datas[i]
                                     type:type name:name
                                 mimeType:mimeTypes
                            progressBlock:^(int64_t bytesWritten, int64_t totalBytes) {
                                if (progressBlock) progressBlock(bytesWritten,
                                                                 totalBytes);
                                
                            } successBlock:^(id response) {
                                [responses addObject:response];
                                
                                dispatch_group_leave(uploadGroup);
                                
                                [sessions removeObject:session];
                                
                            } failBlock:^(NSError *error) {
                                NSError *Error = [NSError errorWithDomain:url code:-999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"第%d次上传失败",i]}];
                                
                                [failResponse addObject:Error];
                                
                                dispatch_group_leave(uploadGroup);
                                
                                [sessions removeObject:session];
                            }];
        
        [session resume];
        
        if (session) [sessions addObject:session];
    }
    
    [[self allTasks] addObjectsFromArray:sessions];
    
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        if (responses.count > 0) {
            if (successBlock) {
                successBlock([responses copy]);
                if (sessions.count > 0) {
                    [[self allTasks] removeObjectsInArray:sessions];
                }
            }
        }
        
        if (failResponse.count > 0) {
            if (failBlock) {
                failBlock([failResponse copy]);
                if (sessions.count > 0) {
                    [[self allTasks] removeObjectsInArray:sessions];
                }
            }
        }
        
    });
    
    return [sessions copy];
}

#pragma mark - 下载
+ (XDURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(XDDownloadProgress)progressBlock
                         successBlock:(XDDownloadSuccessBlock)successBlock
                            failBlock:(XDDownloadFailBlock)failBlock {
    NSString *type = nil;
    NSArray *subStringArr = nil;
    __block XDURLSessionTask *session = nil;
    
    NSURL *fileUrl = [[XDCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
    
    if (fileUrl) {
        if (successBlock) successBlock(fileUrl);
        return nil;
    }
    
    if (url) {
        subStringArr = [url componentsSeparatedByString:@"."];
        if (subStringArr.count > 0) {
            type = subStringArr[subStringArr.count - 1];
        }
    }
    
    AFHTTPSessionManager *manager = [self manager];
    //响应内容序列化为二进制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    session = [manager GET:url
                parameters:nil
                  progress:^(NSProgress * _Nonnull downloadProgress) {
                      if (progressBlock) progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      if (successBlock) {
                          NSData *dataObj = (NSData *)responseObject;
                          
                          [[XDCacheManager shareManager] storeDownloadData:dataObj requestUrl:url];
                          
                          NSURL *downFileUrl = [[XDCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
                          
                          successBlock(downFileUrl);
                      }
                      
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) {
                          failBlock (error);
                      }
                  }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
    
}

#pragma mark - other method
+ (void)setupTimeout:(NSTimeInterval)timeout {
    requestTimeout = timeout;
}

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(XDURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[XDURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) return;
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(XDURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[XDURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}

+ (void)configHttpHeader:(NSDictionary *)httpHeader {
    headers = httpHeader;
}

+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}

@end


@implementation XDNetworking (cache)

+ (NSUInteger)totalCacheSize {
    return [[XDCacheManager shareManager] totalCacheSize];
}

+ (NSUInteger)totalDownloadDataSize {
    return [[XDCacheManager shareManager] totalDownloadDataSize];
}

+ (void)clearDownloadData {
    [[XDCacheManager shareManager] clearDownloadData];
}

+ (NSString *)getDownDirectoryPath {
    return [[XDCacheManager shareManager] getDownDirectoryPath];
}

+ (NSString *)getCacheDiretoryPath {

    return [[XDCacheManager shareManager] getCacheDiretoryPath];
}

+ (void)clearTotalCache {
    [[XDCacheManager shareManager] clearTotalCache];
}

@end
