//
//  YGRManga.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRManga.h"
#import "YGRSettingsManager.h"

@implementation YGRManga

#pragma mark - Private Helpers

/**
 *  Reads an integer value out of a dictionary, tolerating missing or
 *  NSNull entries.
 *
 *  @param key        The dictionary key to look up.
 *  @param dictionary The dictionary to read from.
 *
 *  @return The integer value for `key`, or -1 if the key is absent or maps
 *          to NSNull.
 */
- (NSInteger)integerValueForKey:(NSString *)key inDictionary:(NSDictionary *)dictionary
{
    id value = dictionary[key];
    return (value != nil && ![value isEqual:[NSNull null]]) ? [value integerValue] : -1;
}

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _id_ = dictionary[@"id"];
        _sourceId = dictionary[@"sourceId"];
        _url = [[YGRSettingsManager sharedInstance] URLForPath:dictionary[@"url"]];
        _title = dictionary[@"title"];
        _thumbnailUrl = [[YGRSettingsManager sharedInstance]
            URLForPath:dictionary[@"thumbnailUrl"]];
        _thumbnailUrlLastFetched =
            [dictionary[@"thumbnailUrlLastFetched"] integerValue];
        _initialized = [dictionary[@"initialized"] boolValue];
        _artist = dictionary[@"artist"];
        _author = dictionary[@"author"];
        _description_ = dictionary[@"description"];
        _genres = dictionary[@"genre"];
        _status = [YGRMangaStatusUtility mangaStatusFromString:dictionary[@"status"]];
        _inLibrary = [dictionary[@"inLibrary"] boolValue];
        _inLibraryAt = [dictionary[@"inLibraryAt"] integerValue];

        id sourceValue = dictionary[@"source"];
        _source = (sourceValue != nil && ![sourceValue isEqual:[NSNull null]])
                      ? [[YGRSource alloc] initWithDictionary:sourceValue]
                      : nil;

        _meta = dictionary[@"meta"] ?: [NSDictionary dictionary];

        id realUrlValue = dictionary[@"realUrl"];
        _realUrl = (realUrlValue != nil && ![realUrlValue isEqual:[NSNull null]])
                       ? [NSURL URLWithString:realUrlValue]
                       : nil;

        _lastFetchedAt = [dictionary[@"lastFetchedAt"] integerValue];
        _chaptersLastFetchedAt = [dictionary[@"chaptersLastFetchedAt"] integerValue];
        _updateStrategy = [YGRUpdateStrategyUtility
            updateStrategyFromString:dictionary[@"updateStrategy"]];
        _freshDate = [dictionary[@"freshDate"] boolValue];

        _unreadCount = [self integerValueForKey:@"unreadCount" inDictionary:dictionary];
        _downloadCount = [self integerValueForKey:@"downloadCount" inDictionary:dictionary];
        _chapterCount = [self integerValueForKey:@"chapterCount" inDictionary:dictionary];
        _lastReadAt = [self integerValueForKey:@"lastReadAt" inDictionary:dictionary];

        id lastChapterReadValue = dictionary[@"lastChapterRead"];
        _lastChapterRead =
            (lastChapterReadValue != nil && ![lastChapterReadValue isEqual:[NSNull null]])
                ? [[YGRChapter alloc] initWithDictionary:lastChapterReadValue]
                : nil;

        _age = [dictionary[@"age"] integerValue];
        _chaptersAge = [dictionary[@"chaptersAge"] integerValue];
        _trackers = dictionary[@"trackers"] ?: [NSArray array];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString
        stringWithFormat:@"<%@: %p> {\n"
                          "  id_ = %@;\n"
                          "  sourceId = %@;\n"
                          "  url = %@;\n"
                          "  title = %@;\n"
                          "  thumbnailUrl = %@;\n"
                          "  thumbnailUrlLastFetched = %ld;\n"
                          "  initialized = %@;\n"
                          "  artist = %@;\n"
                          "  author = %@;\n"
                          "  description_ = %@;\n"
                          "  genres = %@;\n"
                          "  status = %@;\n"
                          "  inLibrary = %@;\n"
                          "  inLibraryAt = %ld;\n"
                          "  source = %@;\n"
                          "  meta = %@;\n"
                          "  realUrl = %@;\n"
                          "  lastFetchedAt = %ld;\n"
                          "  chaptersLastFetchedAt = %ld;\n"
                          "  updateStrategy = %@;\n"
                          "  freshDate = %@;\n"
                          "  unreadCount = %ld;\n"
                          "  downloadCount = %ld;\n"
                          "  chapterCount = %ld;\n"
                          "  lastReadAt = %ld;\n"
                          "  lastChapterRead = %@;\n"
                          "  age = %ld;\n"
                          "  chaptersAge = %ld;\n"
                          "  trackers = %@;\n"
                          "}",
                         NSStringFromClass([self class]), self, self.id_, self.sourceId, self.url,
                         self.title, self.thumbnailUrl, (long) self.thumbnailUrlLastFetched,
                         self.initialized ? @"YES" : @"NO", self.artist, self.author,
                         self.description_, self.genres,
                         [YGRMangaStatusUtility stringFromMangaStatus:self.status],
                         self.inLibrary ? @"YES" : @"NO", (long) self.inLibraryAt, self.source,
                         self.meta, self.realUrl, (long) self.lastFetchedAt,
                         (long) self.chaptersLastFetchedAt,
                         [YGRUpdateStrategyUtility stringFromUpdateStrategy:self.updateStrategy],
                         self.freshDate ? @"YES" : @"NO", (long) self.unreadCount,
                         (long) self.downloadCount, (long) self.chapterCount,
                         (long) self.lastReadAt, self.lastChapterRead, (long) self.age,
                         (long) self.chaptersAge, self.trackers];
}

@end
