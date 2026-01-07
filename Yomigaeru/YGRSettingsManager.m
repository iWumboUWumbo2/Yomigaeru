//
//  YGRSettingsService.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRSettingsManager.h"
#import "YGRNetworkManager.h"

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
        // Load saved URL from UserDefaults on initialization
        NSString *baseURLString =
            [[NSUserDefaults standardUserDefaults] objectForKey:kServerAddressKey];
        if (baseURLString)
        {
            _serverBaseURL = [NSURL URLWithString:baseURLString];
        }
    }
    return self;
}

- (void)setServerBaseURL:(NSURL *)serverBaseURL
{
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

@end