# XDNetworking
A Network framework based on AFNetworking

# More Infomation
基于AFNetworking3.0封装网络请求功能，API面向业务层更友好，基础功能包括GET、POST、下载、单文件上传、多文件上传、取消网络请求。此外拓展出缓存功能，缓存分为内存缓存和磁盘缓存。

# Usage

将XDNetworking包拉进工程

```objC
#import "XDNetworking.h"
```
GET请求

```ObjC
/**
 *  GET请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (XDURLSessionTask *)getWithUrl:(NSString *)url
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                    progressBlock:(XDGetProgress)progressBlock
                     successBlock:(XDResponseSuccessBlock)successBlock
                        failBlock:(XDResponseFailBlock)failBlock;
```

POST请求

```ObjC
/**
 *  POST请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (XDURLSessionTask *)postWithUrl:(NSString *)url
                             cache:(BOOL)cache
                            params:(NSDictionary *)params
                     progressBlock:(XDPostProgress)progressBlock
                      successBlock:(XDResponseSuccessBlock)successBlock
                         failBlock:(XDResponseFailBlock)failBlock;
```

下载请求

```ObjC
/**
 *  文件下载
 *
 *  @param url           下载文件接口地址
 *  @param progressBlock 下载进度
 *  @param successBlock  成功回调
 *  @param failBlock     下载回调
 *
 *  @return 返回的对象可取消请求
 */
+ (XDURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(XDDownloadProgress)progressBlock
                         successBlock:(XDDownloadSuccessBlock)successBlock
                            failBlock:(XDDownloadFailBlock)failBlock;
```

文件上传

```ObjC
/**
 *  文件上传
 *
 *  @param url              上传文件接口地址
 *  @param data             上传文件数据
 *  @param type             上传文件类型
 *  @param name             上传文件服务器文件夹名
 *  @param mimeType         mimeType
 *  @param progressBlock    上传文件路径
 *	@param successBlock     成功回调
 *	@param failBlock		失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (XDURLSessionTask *)uploadFileWithUrl:(NSString *)url
                                fileData:(NSData *)data
                                    type:(NSString *)type
                                    name:(NSString *)name
                                mimeType:(NSString *)mimeType
                           progressBlock:(XDUploadProgressBlock)progressBlock
                            successBlock:(XDResponseSuccessBlock)successBlock
                               failBlock:(XDResponseFailBlock)failBlock;

```

多文件上传

```ObjC
/**
 *  多文件上传
 *
 *  @param url           上传文件地址
 *  @param datas         数据集合
 *  @param type          类型
 *  @param name          服务器文件夹名
 *  @param mimeType      mimeTypes
 *  @param progressBlock 上传进度
 *  @param successBlock  成功回调
 *  @param failBlock     失败回调
 *
 *  @return 任务集合
 */
+ (NSArray *)uploadMultFileWithUrl:(NSString *)url
                         fileDatas:(NSArray *)datas
                              type:(NSString *)type
                              name:(NSString *)name
                          mimeType:(NSString *)mimeTypes
                     progressBlock:(XDUploadProgressBlock)progressBlock
                      successBlock:(XDMultUploadSuccessBlock)successBlock
                         failBlock:(XDMultUploadFailBlock)failBlock;
```

取消所有网络请求

```OjbC
+ (void)cancleAllRequest;

```
取消单个请求

```ObjC
+ (void)cancelRequestWithURL:(NSString *)url;
```

# Usage Tip
`1. ` 对于cache与否，到时大家针对自己的业务数据的特征来决定是否开启cache,即时性或时效性的数据建议不开启缓存，一般建议开启，开启缓存后会回调两次，第一次获取是缓存数据，第二次获取的是最新的网络数据；
`2. ` 具体使用的时候，建议面向业务层再封装一次Service层或者将网络请求写进MVVM的viewModel中，向controller暴露只面向业务的参数。

# Extension For Future
`1. ` 为缓存添加相应的缓存淘汰算法LRU；
`2. ` 添加请求缓存策略；
`3. ` 再封装面向业务更友好的manager，管理业务层的API，使其方便在不同网络环境下切换（测试环境与正式环境......）

