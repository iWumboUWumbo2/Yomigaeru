//
//  YGRChapter.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRChapter : NSObject

@property (nonatomic, strong) NSString *id_;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) long long uploadDate;
@property (nonatomic, assign) double chapterNumber;
@property (nonatomic, strong) NSString *scanlator;
@property (nonatomic, strong) NSString *mangaId;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) BOOL bookmarked;
@property (nonatomic, assign) NSInteger lastPageRead;
@property (nonatomic, assign) long long lastReadAt;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) long long fetchedAt;
@property (nonatomic, strong) NSURL *realUrl;
@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger chapterCount;
@property (nonatomic, strong) NSDictionary *meta;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)description;

@end
