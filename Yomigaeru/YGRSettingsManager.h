//
//  YGRSettingsService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Wraps `NSUserDefaults` to persist and expose the app's user-configurable
 *  settings: the server address and how many chapters to prefetch in each
 *  direction while reading.
 *
 *  Setting `serverBaseURL` persists the change immediately and posts
 *  `YGRBaseURLDidChangeNotification`, which `YGRNetworkManager` observes to
 *  rebuild its HTTP clients.
 */
@interface YGRSettingsManager : NSObject

#pragma mark - Properties

/** The user-configured base URL of the manga server, e.g. `http://host:4567/`. */
@property (nonatomic, strong) NSURL *serverBaseURL;
/** `serverBaseURL` resolved against the `api/v1/` path; used for API requests. */
@property (nonatomic, strong) NSURL *apiBaseURL;

/** How many upcoming chapters to prefetch while reading; clamped to 2...10. */
@property (nonatomic, assign) NSInteger nextPrefetchCount;
/** How many preceding chapters to prefetch while reading; clamped to 1...10. */
@property (nonatomic, assign) NSInteger previousPrefetchCount;

#pragma mark - Initialization

/**
 *  Returns the shared settings manager instance, loading its properties
 *  from `NSUserDefaults` (or registered defaults) the first time it's
 *  accessed.
 *
 *  @return The singleton `YGRSettingsManager` instance.
 */
+ (instancetype)sharedInstance;

#pragma mark - URL Helpers

/**
 *  Resolves a path against the server's base URL.
 *
 *  @param path The relative (or absolute) path to resolve.
 *
 *  @return The resolved URL.
 */
- (NSURL *)URLForPath:(NSString *)path;

/**
 *  Resolves an endpoint against the server's API base URL.
 *
 *  @param endpoint The relative (or absolute) API endpoint to resolve.
 *
 *  @return The resolved URL.
 */
- (NSURL *)URLForEndpoint:(NSString *)endpoint;

@end