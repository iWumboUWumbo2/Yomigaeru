//
//  YGRNetworkManager.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>

/**
 *  Provides the shared `AFHTTPClient` instances used to talk to the server,
 *  keeping them pointed at the current base URL from `YGRSettingsManager`.
 *
 *  The clients are recreated automatically whenever the base URL changes
 *  (via `YGRBaseURLDidChangeNotification`), so callers should always fetch
 *  a fresh client instance rather than caching one themselves.
 */
@interface YGRNetworkManager : NSObject

#pragma mark - Initialization

/**
 *  Returns the shared network manager instance.
 *
 *  @return The singleton `YGRNetworkManager` instance.
 */
+ (instancetype)sharedManager;

#pragma mark - Clients

/**
 *  The client used for requests whose responses are decoded as JSON.
 *
 *  @return The shared JSON `AFHTTPClient`, rebuilt first if the base URL
 *  has changed since it was last used.
 */
- (AFHTTPClient *)jsonClientInstance;

/**
 *  The client used for plain HTTP requests whose responses are not decoded
 *  (e.g. action endpoints that only care about the status code).
 *
 *  @return The shared plain-HTTP `AFHTTPClient`, rebuilt first if the base
 *  URL has changed since it was last used.
 */
- (AFHTTPClient *)httpClientInstance;

/**
 *  The client used for requests that download images, configured to accept
 *  any `image/` content type and capped at 2 concurrent operations.
 *
 *  @return The shared image `AFHTTPClient`, rebuilt first if the base URL
 *  has changed since it was last used.
 */
- (AFHTTPClient *)imageClientInstance;

@end
