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

/**
 *  Fetches manga and chapter details from the server, and manages a manga's
 *  library membership plus its chapters' read/bookmark/progress state.
 */
@interface YGRMangaService : NSObject

#pragma mark - Fetching

/**
 *  Fetches basic details for a single manga.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param completion Called with the populated `YGRManga` on success, or
 *  `nil` and an error on failure.
 */
- (void)fetchMangaWithId:(NSString *)mangaId
              completion:(void (^)(YGRManga *manga, NSError *error))completion;

/**
 *  Fetches full details for a single manga, including fields (such as
 *  `chapterCount`) that the basic fetch does not populate.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param completion Called with the populated `YGRManga` on success, or
 *  `nil` and an error on failure.
 */
- (void)fetchFullMangaWithId:(NSString *)mangaId
                  completion:(void (^)(YGRManga *manga, NSError *error))completion;

#pragma mark - Library Management

/**
 *  Adds a manga to the user's library.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param completion Called with `YES` if the server responded with a
 *  success status code, `NO` if it responded with any other status code
 *  (with a `nil` error in that case), or `NO` and an error if the request
 *  itself failed.
 */
- (void)addToLibraryWithMangaId:(NSString *)mangaId
                     completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Removes a manga from the user's library.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param completion Called with `YES` if the server responded with a
 *  success status code, `NO` if it responded with any other status code
 *  (with a `nil` error in that case), or `NO` and an error if the request
 *  itself failed.
 */
- (void)deleteFromLibraryWithMangaId:(NSString *)mangaId
                          completion:(void (^)(BOOL success, NSError *error))completion;

#pragma mark - Chapters

/**
 *  Fetches the list of chapters for a manga.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param completion Called with the array of `YGRChapter` objects on
 *  success, or `nil` and an error on failure.
 */
- (void)fetchChaptersWithMangaId:(NSString *)mangaId
                      completion:(void (^)(NSArray *chapters, NSError *error))completion;

/**
 *  Fetches a single chapter, including its page list.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param completion Called with the populated `YGRChapter` on success, or
 *  `nil` and an error on failure. Not called at all if `completion` is
 *  `nil`.
 */
- (void)fetchChapterWithMangaId:(NSString *)mangaId
                   chapterIndex:(NSUInteger)chapterIndex
                     completion:(void (^)(YGRChapter *chapter, NSError *error))completion;

/**
 *  Sends a partial update for a chapter (e.g. read/bookmark flags or last
 *  page read) to the server as a form-encoded `PUT` request.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param parameters The form fields to update, as string/number values
 *  keyed by field name (e.g. `@{@"read": @"true"}`).
 *  @param completion Called with `YES` if the server responded with a
 *  success status code, `NO` if it responded with any other status code
 *  (with a `nil` error in that case), or `NO` and an error if the request
 *  itself failed.
 */
- (void)modifyChapterWithMangaId:(NSString *)mangaId
                    chapterIndex:(NSUInteger)chapterIndex
                      parameters:(NSDictionary *)parameters
                      completion:(void (^)(BOOL success, NSError *error))completion;

#pragma mark - Chapter Status

/**
 *  Marks a chapter as read or unread. Convenience wrapper around
 *  `-modifyChapterWithMangaId:chapterIndex:parameters:completion:`.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param readStatus `YES` to mark the chapter read, `NO` to mark it unread.
 *  @param completion Called with `YES` on success, `NO` on a non-success
 *  status code, or `NO` and an error on request failure.
 */
- (void)markReadStatusChapterWithMangaId:(NSString *)mangaId
                            chapterIndex:(NSUInteger)chapterIndex
                              readStatus:(BOOL)readStatus
                              completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Marks a chapter as bookmarked or not. Convenience wrapper around
 *  `-modifyChapterWithMangaId:chapterIndex:parameters:completion:`.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param bookmarkStatus `YES` to bookmark the chapter, `NO` to remove any
 *  existing bookmark.
 *  @param completion Called with `YES` on success, `NO` on a non-success
 *  status code, or `NO` and an error on request failure.
 */
- (void)markBookmarkStatusChapterWithMangaId:(NSString *)mangaId
                                chapterIndex:(NSUInteger)chapterIndex
                              bookmarkStatus:(BOOL)bookmarkStatus
                                  completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Marks all chapters before this one as read (or unread). Convenience
 *  wrapper around `-modifyChapterWithMangaId:chapterIndex:parameters:completion:`.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param markPrevReadStatus `YES` to mark preceding chapters read, `NO` to
 *  mark them unread.
 *  @param completion Called with `YES` on success, `NO` on a non-success
 *  status code, or `NO` and an error on request failure.
 */
- (void)markPrevReadStatusChapterWithMangaId:(NSString *)mangaId
                                chapterIndex:(NSUInteger)chapterIndex
                          markPrevReadStatus:(BOOL)markPrevReadStatus
                                  completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Records the last page the user read within a chapter. Convenience
 *  wrapper around `-modifyChapterWithMangaId:chapterIndex:parameters:completion:`.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param chapterIndex The index of the chapter within the manga.
 *  @param lastPageRead The index of the last page read.
 *  @param completion Called with `YES` on success, `NO` on a non-success
 *  status code, or `NO` and an error on request failure.
 */
- (void)markLastPageReadForChapterWithMangaId:(NSString *)mangaId
                                 chapterIndex:(NSUInteger)chapterIndex
                                 lastPageRead:(NSUInteger)lastPageRead
                                   completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Marks every chapter of a manga as read or unread, by fetching the full
 *  manga (to determine its chapter count) and then updating the "virtual"
 *  chapter at that index, which the server interprets as applying to the
 *  whole manga.
 *
 *  @param mangaId The server-assigned identifier of the manga.
 *  @param readStatus `YES` to mark the manga read, `NO` to mark it unread.
 *  @param completion Called with `NO` and the fetch error if fetching the
 *  full manga fails; otherwise called with the result of the underlying
 *  chapter update (`YES` on success, `NO` on a non-success status code or
 *  request failure).
 */
- (void)markMangaReadStatusWithMangaId:(NSString *)mangaId
                            readStatus:(BOOL)readStatus
                            completion:(void (^)(BOOL success, NSError *error))completion;

@end
