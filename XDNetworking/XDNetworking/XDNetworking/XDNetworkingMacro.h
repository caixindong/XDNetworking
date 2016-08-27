//
//  XDNetworkingMacro.h
//  XDNetworking
//
//  Created by 蔡欣东 on 2016/8/27.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#ifndef XDNetworkingMacro_h
#define XDNetworkingMacro_h

#define XD_ERROR_IMFORMATION @"网络出现错误，请检查网络连接"

#define XD_ERROR [NSError errorWithDomain:@"com.caixindong.XDNetworking.ErrorDomain" code:-999 userInfo:@{ NSLocalizedDescriptionKey:XD_ERROR_IMFORMATION}]


#define XD_NSUSERDEFAULT_GETTER(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define XD_NSUSERDEFAULT_SETTER(value, key) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];[[NSUserDefaults standardUserDefaults] synchronize]

#endif /* XDNetworkingMacro_h */
