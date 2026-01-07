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

- (NSInteger)integerValueForKey:(NSString *)key inDictionary:(NSDictionary *)dictionary
{
    id value = [dictionary objectForKey:key];
    return (value != nil && ![value isEqual:[NSNull null]]) ? [value integerValue] : -1;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _id_ = [dictionary objectForKey:@"id"];
        _sourceId = [dictionary objectForKey:@"sourceId"];
        _url = [[YGRSettingsManager sharedInstance] URLForPath:[dictionary objectForKey:@"url"]];
        _title = [dictionary objectForKey:@"title"];
        _thumbnailUrl = [[YGRSettingsManager sharedInstance]
            URLForPath:[dictionary objectForKey:@"thumbnailUrl"]];
        _thumbnailUrlLastFetched =
            [[dictionary objectForKey:@"thumbnailUrlLastFetched"] integerValue];
        _initialized = [[dictionary objectForKey:@"initialized"] boolValue];
        _artist = [dictionary objectForKey:@"artist"];
        _author = [dictionary objectForKey:@"author"];
        _description_ = [dictionary objectForKey:@"description"];
        _genres = [dictionary objectForKey:@"genre"];
        _status = [YGRMangaStatusUtility mangaStatusFromString:[dictionary objectForKey:@"status"]];
        _inLibrary = [[dictionary objectForKey:@"inLibrary"] boolValue];
        _inLibraryAt = [[dictionary objectForKey:@"inLibraryAt"] integerValue];

        id sourceValue = [dictionary objectForKey:@"source"];
        _source = (sourceValue != nil && ![sourceValue isEqual:[NSNull null]])
                      ? [[YGRSource alloc] initWithDictionary:sourceValue]
                      : nil;

        _meta = [dictionary objectForKey:@"meta"] ?: [NSDictionary dictionary];

        id realUrlValue = [dictionary objectForKey:@"realUrl"];
        _realUrl = (realUrlValue != nil && ![realUrlValue isEqual:[NSNull null]])
                       ? [NSURL URLWithString:realUrlValue]
                       : nil;

        _lastFetchedAt = [[dictionary objectForKey:@"lastFetchedAt"] integerValue];
        _chaptersLastFetchedAt = [[dictionary objectForKey:@"chaptersLastFetchedAt"] integerValue];
        _updateStrategy = [YGRUpdateStrategyUtility
            updateStrategyFromString:[dictionary objectForKey:@"updateStrategy"]];
        _freshDate = [[dictionary objectForKey:@"freshDate"] boolValue];

        _unreadCount = [self integerValueForKey:@"unreadCount" inDictionary:dictionary];
        _downloadCount = [self integerValueForKey:@"downloadCount" inDictionary:dictionary];
        _chapterCount = [self integerValueForKey:@"chapterCount" inDictionary:dictionary];
        _lastReadAt = [self integerValueForKey:@"lastReadAt" inDictionary:dictionary];

        id lastChapterReadValue = [dictionary objectForKey:@"lastChapterRead"];
        _lastChapterRead =
            (lastChapterReadValue != nil && ![lastChapterReadValue isEqual:[NSNull null]])
                ? [[YGRChapter alloc] initWithDictionary:lastChapterReadValue]
                : nil;

        _age = [[dictionary objectForKey:@"age"] integerValue];
        _chaptersAge = [[dictionary objectForKey:@"chaptersAge"] integerValue];
        _trackers = [dictionary objectForKey:@"trackers"] ?: [NSArray array];
    }
    return self;
}

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
