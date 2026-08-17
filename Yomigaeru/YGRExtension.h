//
//  YGRExtension.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A source extension (a downloadable manga source plugin) as reported by
 *  the extension repository/catalog, including its install/update state.
 */
@interface YGRExtension : NSObject

#pragma mark - Properties

/** The URL of the repository the extension was listed from. */
@property (nonatomic, strong) NSURL *repo;
/** The filename of the extension's installable package. */
@property (nonatomic, copy) NSString *apkName;
/** The URL of the extension's icon, resolved against the server base URL. */
@property (nonatomic, strong) NSURL *iconUrl;
/** The extension's display name. */
@property (nonatomic, copy) NSString *name;
/** A lowercased copy of `name`, precomputed for case-insensitive searching/sorting. */
@property (nonatomic, strong) NSString *lowerName;
/** The extension's package identifier. */
@property (nonatomic, copy) NSString *pkgName;
/** The extension's version string. */
@property (nonatomic, copy) NSString *versionName;
/** The extension's version code, used to detect available updates. */
@property (nonatomic, assign) NSInteger versionCode;
/** The language code of the source(s) the extension provides. */
@property (nonatomic, copy) NSString *lang;
/** Whether the extension is flagged as NSFW. */
@property (nonatomic, assign) BOOL isNsfw;
/** Whether the extension is currently installed. */
@property (nonatomic, assign) BOOL installed;
/** Whether a newer version of the extension is available. */
@property (nonatomic, assign) BOOL hasUpdate;
/** Whether the installed extension is obsolete/no longer supported. */
@property (nonatomic, assign) BOOL obsolete;

#pragma mark - Initialization

/**
 *  Creates an extension from a server JSON dictionary.
 *
 *  Maps `repo`, `apkName`, `iconUrl`, `name`, `pkgName`, `versionName`,
 *  `versionCode`, `lang`, `isNsfw`, `installed`, `hasUpdate`, and `obsolete`
 *  keys onto the receiver's properties. `iconUrl` is resolved via
 *  YGRSettingsManager against the configured server, and `lowerName` is
 *  derived from `name`.
 *
 *  @param dictionary The decoded JSON dictionary describing the extension.
 *
 *  @return An initialized YGRExtension instance.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a human-readable, multi-line dump of the receiver's properties.
 *
 *  @return A debug description string listing every property and its value.
 */
- (NSString *)description;

@end
