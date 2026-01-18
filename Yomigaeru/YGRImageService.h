//
//  YGRImageService.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/17.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRImageService : NSObject

+ (instancetype)sharedService;

- (void)fetchThumbnailWithMangaId:(NSString *)mangaId
                       completion:(void (^)(UIImage *thumbnailImage, NSError *error))completion;

- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
                  completion:(void (^)(UIImage *pageData, NSError *error))completion;

@end
