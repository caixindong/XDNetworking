# XDNetworking 1.21
A Network framework based on AFNetworking

# More Infomation
基于AFNetworking3.0封装网络请求功能，API面向业务层更友好，基础功能包括GET、POST、下载、单文件上传、多文件上传、取消网络请求。此外拓展出缓存功能，缓存分为内存缓存和磁盘缓存。       
1.1版本：新增重复请求管理功能。        
1.2版本：上层的API没有修改，缓存那里新增LRU缓存淘汰算法，具体实现，可以看XD_LRUManager。
1.21版本：修改了部分API，新添加一个缓存管理类，支持过期检验，优化LRU算法的实现。
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
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请   求，用旧请求)
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (XDURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
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
 *  @param refresh          解释同上
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (XDURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
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

获取当前正在运行的任务

```ObjC
/**
 *  正在运行的网络任务
 *
 *  @return 
 */
+ (NSArray *)currentRunningTasks;
```

取消所有网络请求

```OjbC
+ (void)cancleAllRequest;

```
取消下载请求

```ObjC
+ (void)cancelRequestWithURL:(NSString *)url;
```

获取缓存大小

```ObjC
/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
+ (NSUInteger)totalCacheSize;
```

清理缓存

```ObjC
/**
 *  清除所有缓存
 */
+ (void)clearTotalCache;
```

自动清理缓存

```ObjC
    //每次网络请求的时候，检查此时磁盘中的缓存大小，阈值默认是40MB，如果超过阈值，则清理LRU缓存,同时也会清理过期缓存，缓存默认SSL是7天，磁盘缓存的大小和SSL的设置可以通过该方法[XDCacheManager shareManager] setCacheTime: diskCapacity:]设置
    [[XDCacheManager shareManager] clearLRUCache];
```



# Usage Tip
`1. ` 对于cache与否，到时大家针对自己的业务数据的特征来决定是否开启cache,即时性或时效性的数据建议不开启缓存，一般建议开启，开启缓存后会回调两次，第一次获取是缓存数据，第二次获取的是最新的网络数据；        
`2. ` 新版本多了一个刷新请求参数，设置它是为了解决重复请求的问题，举个例子，当我们在列表里面上拉获取更多数据的时候，有时候因为网络慢，还没有回调响应刷新出数据，这时候我们可能不断去上拉列表，如果业务层不判断，就会发起很多重复的请求。遇到重复请求，若参数设为YES，则会取消旧的请求，用新的请求，若设为NO，则忽略新请求，用旧请求。       
`3. ` 具体使用的时候，建议面向业务层再封装一次Service层或者将网络请求写进MVVM的viewModel中，向controller暴露只面向业务的参数。      

# Extension For Future
每个请求的API对象化，业务人员能够更加方便地对每个请求进行配置，配置相应的请求参数、缓存策略以及其他配置参数，方便管理业务层的API...   

