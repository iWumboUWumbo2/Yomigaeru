//
//  YGRNetworkManager.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface YGRNetworkManager : NSObject

+ (instancetype)sharedManager;
- (AFHTTPClient *)jsonClientInstance;
- (AFHTTPClient *)httpClientInstance;
- (AFHTTPClient *)imageClientInstance;

@end
