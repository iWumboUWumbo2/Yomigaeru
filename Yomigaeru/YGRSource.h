//
//  YGRSource.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A manga source (an installed extension's content provider), as reported
 *  by the server.
 */
@interface YGRSource : NSObject

#pragma mark - Properties

/** The source's server-assigned identifier. */
@property (nonatomic, copy) NSString *id_;
/** The source's display name. */
@property (nonatomic, copy) NSString *name;
/** A lowercased copy of `name`, precomputed for case-insensitive searching/sorting. */
@property (nonatomic, strong) NSString *lowerName;
/** The language code the source provides content in. */
@property (nonatomic, copy) NSString *lang;
/** The URL of the source's icon, resolved against the server base URL. */
@property (nonatomic, strong) NSURL *iconUrl;
/** Whether the source supports fetching a "latest updates" listing. */
@property (nonatomic, assign) BOOL supportsLatest;
/** Whether the source exposes user-configurable settings. */
@property (nonatomic, assign) BOOL isConfigurable;
/** Whether the source is flagged as NSFW. */
@property (nonatomic, assign) BOOL isNsfw;
/** The source's display name, formatted for presentation (e.g. including language). */
@property (nonatomic, copy) NSString *displayName;

#pragma mark - Initialization

/**
 *  Creates a source from a server JSON dictionary.
 *
 *  Maps `id`, `name`, `lang`, `iconUrl`, `supportsLatest`, `isConfigurable`,
 *  `isNsfw`, and `displayName` keys onto the receiver's properties.
 *  `iconUrl` is resolved via YGRSettingsManager against the configured
 *  server, and `lowerName` is derived from `name`.
 *
 *  @param dictionary The decoded JSON dictionary describing the source.
 *
 *  @return An initialized YGRSource instance.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a human-readable, multi-line dump of the receiver's properties.
 *
 *  @return A debug description string listing every property and its value.
 */
- (NSString *)description;

@end
