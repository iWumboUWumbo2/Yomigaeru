//
//  YGRImageService.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/17.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Fetches and caches manga thumbnail and page images from the server.
 *
 *  Thumbnails and pages are each kept in their own in-memory `NSCache`, so
 *  repeat requests for the same image can be served without hitting the
 *  network; the caches are cleared on memory warnings.
 */
@interface YGRImageService : NSObject

#pragma mark - Initialization

/**
 *  Returns the shared image service instance.
 *
 *  @return The singleton `YGRImageService` instance.
 */
+ (instancetype)sharedService;

#pragma mark - Thumbnails

/**
 *  Fetches (or returns a cached) thumbnail image for a manga.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param completion Called with the thumbnail image on success, or `nil`
 *  and an error if the image could not be fetched or decoded.
 */
- (void)fetchThumbnailWithMangaId:(NSString *)mangaId
                       completion:(void (^)(UIImage *thumbnailImage, NSError *error))completion;

#pragma mark - Pages

/**
 *  Fetches (or returns a cached) page image for a manga chapter.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param pageIndex The index of the page within the chapter.
 *  @param priority The queue priority to assign to the underlying network
 *  operation, allowing callers to prioritize the currently visible page
 *  over prefetched ones.
 *  @param completion Called with the page image on success, or `nil` and an
 *  error on failure.
 */
- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
                    priority:(NSOperationQueuePriority)priority
                  completion:(void (^)(UIImage *pageData, NSError *error))completion;

@end
