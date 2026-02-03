//
//  YGRSettingsService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRSettingsManager : NSObject

@property (nonatomic, strong) NSURL *serverBaseURL;
@property (nonatomic, strong) NSURL *apiBaseURL;

@property (nonatomic, assign) NSInteger nextPrefetchCount;
@property (nonatomic, assign) NSInteger previousPrefetchCount;

+ (instancetype)sharedInstance;

- (NSURL *)URLForPath:(NSString *)path;
- (NSURL *)URLForEndpoint:(NSString *)endpoint;

@end