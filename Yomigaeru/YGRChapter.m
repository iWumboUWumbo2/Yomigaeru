//
//  YGRChapter.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRChapter.h"

@implementation YGRChapter

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _id_ = [dictionary[@"id"] description];
        _url = [NSURL URLWithString:dictionary[@"url"]];
        _name = dictionary[@"name"];
        _uploadDate = [dictionary[@"uploadDate"] longLongValue];
        _chapterNumber = [dictionary[@"chapterNumber"] doubleValue];
        _scanlator = dictionary[@"scanlator"];
        _mangaId = dictionary[@"mangaId"];
        _read = [dictionary[@"read"] boolValue];
        _bookmarked = [dictionary[@"bookmarked"] boolValue];
        _lastPageRead = [dictionary[@"lastPageRead"] integerValue];
        _lastReadAt = [dictionary[@"lastReadAt"] longLongValue];
        _index = [dictionary[@"index"] integerValue];
        _fetchedAt = [dictionary[@"fetchedAt"] longLongValue];
        _realUrl = [NSURL URLWithString:dictionary[@"realUrl"]];
        _downloaded = [dictionary[@"downloaded"] boolValue];
        _pageCount = [dictionary[@"pageCount"] integerValue];
        _chapterCount = [dictionary[@"chapterCount"] integerValue];
        _meta = dictionary[@"meta"] ?: [NSDictionary dictionary];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> {\n"
                                       "  id_ = %@;\n"
                                       "  url = %@;\n"
                                       "  name = %@;\n"
                                       "  uploadDate = %lld;\n"
                                       "  chapterNumber = %.3f;\n"
                                       "  scanlator = %@;\n"
                                       "  mangaId = %@;\n"
                                       "  read = %@;\n"
                                       "  bookmarked = %@;\n"
                                       "  lastPageRead = %ld;\n"
                                       "  lastReadAt = %lld;\n"
                                       "  index = %ld;\n"
                                       "  fetchedAt = %lld;\n"
                                       "  realUrl = %@;\n"
                                       "  downloaded = %@;\n"
                                       "  pageCount = %ld;\n"
                                       "  chapterCount = %ld;\n"
                                       "  meta = %@;\n"
                                       "}",
                                      NSStringFromClass([self class]), self, self.id_, self.url,
                                      self.name, self.uploadDate, self.chapterNumber,
                                      self.scanlator, self.mangaId, self.read ? @"YES" : @"NO",
                                      self.bookmarked ? @"YES" : @"NO", (long) self.lastPageRead,
                                      self.lastReadAt, (long) self.index, self.fetchedAt,
                                      self.realUrl, self.downloaded ? @"YES" : @"NO",
                                      (long) self.pageCount, (long) self.chapterCount, self.meta];
}

@end
