//
//  YGRMangaService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRChapter.h"
#import "YGRManga.h"
#import <Foundation/Foundation.h>

@interface YGRMangaService : NSObject

- (void)fetchMangaWithId:(NSString *)mangaId
              completion:(void (^)(YGRManga *manga, NSError *error))completion;

- (void)fetchFullMangaWithId:(NSString *)mangaId
                  completion:(void (^)(YGRManga *manga, NSError *error))completion;

- (void)addToLibraryWithMangaId:(NSString *)mangaId
                     completion:(void (^)(BOOL success, NSError *error))completion;

- (void)deleteFromLibraryWithMangaId:(NSString *)mangaId
                          completion:(void (^)(BOOL success, NSError *error))completion;

- (void)fetchChaptersWithMangaId:(NSString *)mangaId
                      completion:(void (^)(NSArray *chapters, NSError *error))completion;

- (void)fetchChapterWithMangaId:(NSString *)mangaId
                   chapterIndex:(NSUInteger)chapterIndex
                     completion:(void (^)(YGRChapter *chapter, NSError *error))completion;

- (void)markReadStatusChapterWithMangaId:(NSString *)mangaId
                            chapterIndex:(NSUInteger)chapterIndex
                              readStatus:(BOOL)readStatus
                              completion:(void (^)(BOOL success, NSError *error))completion;

- (void)markBookmarkStatusChapterWithMangaId:(NSString *)mangaId
                                chapterIndex:(NSUInteger)chapterIndex
                              bookmarkStatus:(BOOL)bookmarkStatus
                                  completion:(void (^)(BOOL success, NSError *error))completion;

- (void)markPrevReadStatusChapterWithMangaId:(NSString *)mangaId
                                chapterIndex:(NSUInteger)chapterIndex
                          markPrevReadStatus:(BOOL)markPrevReadStatus
                                  completion:(void (^)(BOOL success, NSError *error))completion;

- (void)markLastPageReadForChapterWithMangaId:(NSString *)mangaId
                                 chapterIndex:(NSUInteger)chapterIndex
                                 lastPageRead:(NSUInteger)lastPageRead
                                   completion:(void (^)(BOOL success, NSError *error))completion;

- (void)markMangaReadStatusWithMangaId:(NSString *)mangaId
                            readStatus:(BOOL)readStatus
                            completion:(void (^)(BOOL success, NSError *error))completion;

@end
