//
//  YGRManga.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGRChapter.h"
#import "YGRSource.h"

#import "YGRMangaStatusUtility.h"
#import "YGRUpdateStrategyUtility.h"

/**
 *  A manga series, including its metadata, source, library membership,
 *  and read/download progress, as reported by the server.
 */
@interface YGRManga : NSObject

#pragma mark - Core Properties

/** The manga's server-assigned identifier. */
@property (nonatomic, copy) NSString *id_;
/** The identifier of the source this manga belongs to. */
@property (nonatomic, copy) NSString *sourceId;
/** The URL the manga was fetched from, resolved against the server base URL. */
@property (nonatomic, strong) NSURL *url;
/** The manga's display title. */
@property (nonatomic, copy) NSString *title;
/** The URL of the manga's thumbnail/cover image, resolved against the server base URL. */
@property (nonatomic, strong) NSURL *thumbnailUrl;
/** Unix timestamp of when the thumbnail URL was last fetched/refreshed. */
@property (nonatomic, assign) NSInteger thumbnailUrlLastFetched;
/** Whether the manga's full metadata has been fetched from the source. */
@property (nonatomic, assign) BOOL initialized;
/** The manga's credited artist. */
@property (nonatomic, copy) NSString *artist;
/** The manga's credited author. */
@property (nonatomic, copy) NSString *author;
/** The manga's synopsis/description. */
@property (nonatomic, copy) NSString *description_;
/** The manga's genre tags. */
@property (nonatomic, strong) NSArray *genres;
/** The manga's publication status (ongoing, completed, etc). */
@property (nonatomic, assign) YGRMangaStatus status;
/** Whether the manga has been added to the user's library. */
@property (nonatomic, assign) BOOL inLibrary;
/** Unix timestamp of when the manga was added to the library. */
@property (nonatomic, assign) NSInteger inLibraryAt;
/** The source this manga belongs to, if it was included in the response payload. */
@property (nonatomic, strong) YGRSource *source;
/** Arbitrary server-supplied metadata associated with the manga. */
@property (nonatomic, strong) NSDictionary *meta;
/** The manga's real/canonical URL, as opposed to a proxied one. */
@property (nonatomic, strong) NSURL *realUrl;
/** Unix timestamp of when the manga's details were last fetched. */
@property (nonatomic, assign) NSInteger lastFetchedAt;
/** Unix timestamp of when the manga's chapter list was last fetched. */
@property (nonatomic, assign) NSInteger chaptersLastFetchedAt;
/** The strategy used to decide whether this manga should be re-fetched on update. */
@property (nonatomic, assign) YGRUpdateStrategy updateStrategy;
/** Whether the manga's date-related fields are considered fresh/up to date. */
@property (nonatomic, assign) BOOL freshDate;

#pragma mark - Reading Progress Properties

/** The number of unread chapters, or -1 if not provided by the server. */
@property (nonatomic, assign) NSInteger unreadCount;
/** The number of downloaded chapters, or -1 if not provided by the server. */
@property (nonatomic, assign) NSInteger downloadCount;
/** The total number of chapters, or -1 if not provided by the server. */
@property (nonatomic, assign) NSInteger chapterCount;
/** Unix timestamp of when a chapter of this manga was last read, or -1 if not provided. */
@property (nonatomic, assign) NSInteger lastReadAt;
/** The last chapter the user read, if the server included one. */
@property (nonatomic, strong) YGRChapter *lastChapterRead;

#pragma mark - Tracker Properties

/** The manga's age (days since last update), as supplied by the server. */
@property (nonatomic, assign) NSInteger age;
/** The age (days since last update) of the manga's chapter list. */
@property (nonatomic, assign) NSInteger chaptersAge;
/** The tracking service entries associated with this manga. */
@property (nonatomic, strong) NSArray *trackers;

#pragma mark - Initialization

/**
 *  Creates a manga from a server JSON dictionary.
 *
 *  Maps the bulk of the receiver's properties directly from like-named
 *  dictionary keys (e.g. `title`, `artist`, `genre` -> `genres`). `url` and
 *  `thumbnailUrl` are resolved via YGRSettingsManager against the server
 *  base URL; `status` and `updateStrategy` are parsed via
 *  YGRMangaStatusUtility and YGRUpdateStrategyUtility respectively; `source`
 *  and `lastChapterRead` are recursively initialized from nested
 *  dictionaries when present and non-null; `meta` falls back to an empty
 *  dictionary and `trackers` falls back to an empty array when absent; and
 *  `unreadCount`, `downloadCount`, `chapterCount`, and `lastReadAt` default
 *  to -1 when their keys are missing or null.
 *
 *  @param dictionary The decoded JSON dictionary describing the manga.
 *
 *  @return An initialized YGRManga instance.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a human-readable, multi-line dump of the receiver's properties.
 *
 *  @return A debug description string listing every property and its value.
 */
- (NSString *)description;

@end
