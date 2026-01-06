//
//  YGRSettingsService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kServerAddressKey = @"serverAddress";

@interface YGRSettingsManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSURL *serverBaseURL;
@property (nonatomic, strong) NSURL *apiBaseURL;

- (NSURL *)URLForPath:(NSString *)path;
- (NSURL *)URLForEndpoint:(NSString *)endpoint;

@end