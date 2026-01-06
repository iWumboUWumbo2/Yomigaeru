//
//  YGRChapter.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRChapter.h"

@implementation YGRChapter

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _id_ = [[dictionary objectForKey:@"id"] description];
        _url = [NSURL URLWithString:[dictionary objectForKey:@"url"]];
        _name = [dictionary objectForKey:@"name"];
        _uploadDate = [[dictionary objectForKey:@"uploadDate"] longLongValue];
        _chapterNumber = [[dictionary objectForKey:@"chapterNumber"] doubleValue];
        _scanlator = [dictionary objectForKey:@"scanlator"];
        _mangaId = [dictionary objectForKey:@"mangaId"];
        _read = [[dictionary objectForKey:@"read"] boolValue];
        _bookmarked = [[dictionary objectForKey:@"bookmarked"] boolValue];
        _lastPageRead = [[dictionary objectForKey:@"lastPageRead"] integerValue];
        _lastReadAt = [[dictionary objectForKey:@"lastReadAt"] longLongValue];
        _index = [[dictionary objectForKey:@"index"] integerValue];
        _fetchedAt = [[dictionary objectForKey:@"fetchedAt"] longLongValue];
        _realUrl = [NSURL URLWithString:[dictionary objectForKey:@"realUrl"]];
        _downloaded = [[dictionary objectForKey:@"downloaded"] boolValue];
        _pageCount = [[dictionary objectForKey:@"pageCount"] integerValue];
        _chapterCount = [[dictionary objectForKey:@"chapterCount"] integerValue];
        _meta = [dictionary objectForKey:@"meta"] ?: [NSDictionary dictionary];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<%@: %p> {\n"
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
            NSStringFromClass([self class]), self,
            self.id_,
            self.url,
            self.name,
            self.uploadDate,
            self.chapterNumber,
            self.scanlator,
            self.mangaId,
            self.read ? @"YES" : @"NO",
            self.bookmarked ? @"YES" : @"NO",
            (long)self.lastPageRead,
            self.lastReadAt,
            (long)self.index,
            self.fetchedAt,
            self.realUrl,
            self.downloaded ? @"YES" : @"NO",
            (long)self.pageCount,
            (long)self.chapterCount,
            self.meta];
}


@end
