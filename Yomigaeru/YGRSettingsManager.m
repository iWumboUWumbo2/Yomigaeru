//
//  YGRSettingsService.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRSettingsManager.h"
#import "YGRNetworkManager.h"

static NSString *const kServerAddressKey = @"serverAddress";
static NSString *const kNextPrefetchCountKey = @"nextPrefetchCount";
static NSString *const kPreviousPrefetchCountKey = @"previousPrefetchCount";

@interface YGRSettingsManager ()

@end

@implementation YGRSettingsManager

+ (instancetype)sharedInstance
{
    static YGRSettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Register app defaults (only used if nothing is saved yet)
        [defaults registerDefaults:@{
                                     kServerAddressKey : @"http://localhost:4567/",
                                     kNextPrefetchCountKey : @(2),
                                     kPreviousPrefetchCountKey: @(1)
                                     }];
        
        // Server Address
        NSString *baseURLString = [defaults stringForKey:kServerAddressKey];
        _serverBaseURL = [NSURL URLWithString:baseURLString];
        _apiBaseURL = [NSURL URLWithString:@"api/v1/" relativeToURL:_serverBaseURL];
        
        // Prefetch Count
        _nextPrefetchCount = [defaults integerForKey:kNextPrefetchCountKey];
        _previousPrefetchCount = [defaults integerForKey:kPreviousPrefetchCountKey];
    }
    return self;
}

- (void)setServerBaseURL:(NSURL *)serverBaseURL
{
    if (!serverBaseURL)
    {
        return;
    }

    _serverBaseURL = serverBaseURL;
    _apiBaseURL = [NSURL URLWithString:@"api/v1/" relativeToURL:self.serverBaseURL];

    [[NSUserDefaults standardUserDefaults] setObject:serverBaseURL.absoluteString
                                              forKey:kServerAddressKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"YGRBaseURLDidChangeNotification"
                                                        object:nil];
}

- (NSURL *)URLForPath:(NSString *)path
{
    return [NSURL URLWithString:path relativeToURL:self.serverBaseURL];
}

- (NSURL *)URLForEndpoint:(NSString *)endpoint
{
    return [NSURL URLWithString:endpoint relativeToURL:[self apiBaseURL]];
}

- (void)setNextPrefetchCount:(NSInteger)prefetchCount
{
    prefetchCount = MIN(10, MAX(2, prefetchCount));
    _nextPrefetchCount = prefetchCount;
    
    [[NSUserDefaults standardUserDefaults] setInteger:prefetchCount
                                               forKey:kNextPrefetchCountKey];
}

- (void)setPreviousPrefetchCount:(NSInteger)prefetchCount
{
    prefetchCount = MIN(10, MAX(1, prefetchCount));
    _previousPrefetchCount = prefetchCount;
    
    [[NSUserDefaults standardUserDefaults] setInteger:prefetchCount
                                               forKey:kPreviousPrefetchCountKey];
}

@end