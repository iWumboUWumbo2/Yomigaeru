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

@interface YGRManga : NSObject

@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *sourceId;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *thumbnailUrl;
@property (nonatomic, assign) NSInteger thumbnailUrlLastFetched;
@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, strong) NSArray *genres;
@property (nonatomic, assign) YGRMangaStatus status;
@property (nonatomic, assign) BOOL inLibrary;
@property (nonatomic, assign) NSInteger inLibraryAt;
@property (nonatomic, strong) YGRSource *source;
@property (nonatomic, strong) NSDictionary *meta;
@property (nonatomic, strong) NSURL *realUrl;
@property (nonatomic, assign) NSInteger lastFetchedAt;
@property (nonatomic, assign) NSInteger chaptersLastFetchedAt;
@property (nonatomic, assign) YGRUpdateStrategy updateStrategy;
@property (nonatomic, assign) BOOL freshDate;

@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSInteger downloadCount;
@property (nonatomic, assign) NSInteger chapterCount;
@property (nonatomic, assign) NSInteger lastReadAt;
@property (nonatomic, strong) YGRChapter *lastChapterRead;

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger chaptersAge;
@property (nonatomic, strong) NSArray *trackers;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)description;

@end
