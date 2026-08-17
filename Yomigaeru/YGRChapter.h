//
//  YGRChapter.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A single chapter of a manga, including its read/bookmark/download state
 *  and pagination info, as reported by the server.
 */
@interface YGRChapter : NSObject

#pragma mark - Properties

/** The chapter's server-assigned identifier, stringified. */
@property (nonatomic, copy) NSString *id_;
/** The URL the chapter was fetched from. */
@property (nonatomic, strong) NSURL *url;
/** The chapter's display name. */
@property (nonatomic, copy) NSString *name;
/** Unix timestamp (milliseconds) of when the chapter was uploaded to the source. */
@property (nonatomic, assign) long long uploadDate;
/** The chapter's number within the manga (e.g. 12.5 for a half chapter). */
@property (nonatomic, assign) double chapterNumber;
/** The name of the group/individual who scanlated the chapter, if any. */
@property (nonatomic, copy) NSString *scanlator;
/** The identifier of the manga this chapter belongs to. */
@property (nonatomic, copy) NSString *mangaId;
/** Whether the chapter has been marked as read. */
@property (nonatomic, assign) BOOL read;
/** Whether the chapter has been bookmarked. */
@property (nonatomic, assign) BOOL bookmarked;
/** The index of the last page the user read, or -1/0 if unread. */
@property (nonatomic, assign) NSInteger lastPageRead;
/** Unix timestamp (milliseconds) of when the chapter was last read. */
@property (nonatomic, assign) long long lastReadAt;
/** The chapter's position within its manga's chapter list. */
@property (nonatomic, assign) NSInteger index;
/** Unix timestamp (milliseconds) of when the chapter's page list was last fetched. */
@property (nonatomic, assign) long long fetchedAt;
/** The chapter's real/canonical URL, as opposed to a proxied one. */
@property (nonatomic, strong) NSURL *realUrl;
/** Whether the chapter's pages have been downloaded for offline reading. */
@property (nonatomic, assign) BOOL downloaded;
/** The total number of pages in the chapter. */
@property (nonatomic, assign) NSInteger pageCount;
/** The total number of chapters in the parent manga at the time this was fetched. */
@property (nonatomic, assign) NSInteger chapterCount;
/** Arbitrary server-supplied metadata associated with the chapter. */
@property (nonatomic, strong) NSDictionary *meta;

#pragma mark - Initialization

/**
 *  Creates a chapter from a server JSON dictionary.
 *
 *  Maps `id`, `url`, `name`, `uploadDate`, `chapterNumber`, `scanlator`,
 *  `mangaId`, `read`, `bookmarked`, `lastPageRead`, `lastReadAt`, `index`,
 *  `fetchedAt`, `realUrl`, `downloaded`, `pageCount`, `chapterCount`, and
 *  `meta` keys onto the receiver's properties; `meta` falls back to an
 *  empty dictionary when the key is absent.
 *
 *  @param dictionary The decoded JSON dictionary describing the chapter.
 *
 *  @return An initialized YGRChapter instance.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a human-readable, multi-line dump of the receiver's properties.
 *
 *  @return A debug description string listing every property and its value.
 */
- (NSString *)description;

@end
