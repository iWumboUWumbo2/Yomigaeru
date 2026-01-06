//
//  YGRMangaService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRManga.h"
#import "YGRChapter.h"

@interface YGRMangaService : NSObject

- (void)fetchMangaWithId:(NSString *)mangaId
              completion:(void (^)(YGRManga *manga, NSError *error))completion;

- (void)fetchFullMangaWithId:(NSString *)mangaId
                  completion:(void (^)(YGRManga *manga, NSError *error))completion;

- (void)fetchThumbnailWithMangaId:(NSString *)mangaId
                       completion:(void (^)(UIImage *thumbnailImage, NSError *error))completion;

- (void)addToLibraryWithMangaId:(NSString *)mangaId
                     completion:(void (^)(BOOL success, NSError *error))completion;

- (void)deleteFromLibraryWithMangaId:(NSString *)mangaId
                          completion:(void (^)(BOOL success, NSError *error))completion;

- (void)fetchChaptersWithMangaId:(NSString *)mangaId
                      completion:(void (^)(NSArray *chapters, NSError *error))completion;

- (void)fetchChapterWithMangaId:(NSString *)mangaId
                   chapterIndex:(NSUInteger)chapterIndex
                     completion:(void (^)(YGRChapter *chapter, NSError *error))completion;

- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
                  completion:(void (^)(UIImage *pageData, NSError *error))completion;

@end
