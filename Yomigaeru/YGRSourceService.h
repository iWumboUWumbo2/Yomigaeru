//
//  YGRSourceService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRSource.h"
#import <Foundation/Foundation.h>

/**
 *  Fetches source (a.k.a. extension catalog/repository) metadata and the
 *  paginated manga listings each source exposes: popular, latest, and
 *  search results.
 */
@interface YGRSourceService : NSObject

#pragma mark - Sources

/**
 *  Fetches the list of all sources known to the server.
 *
 *  @param completion Called with the array of `YGRSource` objects on
 *  success, or `nil` and an error on failure.
 */
- (void)fetchAllSourcesWithCompletion:(void (^)(NSArray *sources, NSError *error))completion;

/**
 *  Fetches details for a single source.
 *
 *  @param sourceId The server-assigned identifier of the source.
 *  @param completion Called with the populated `YGRSource` on success, or
 *  `nil` and an error on failure.
 */
- (void)fetchSourceWithId:(NSString *)sourceId
               completion:(void (^)(YGRSource *source, NSError *error))completion;

#pragma mark - Manga Listings

/**
 *  Fetches a page of a source's "popular manga" listing.
 *
 *  @param sourceId The server-assigned identifier of the source.
 *  @param pageNum The page number to fetch.
 *  @param completion Called with the page's array of `YGRManga` objects and
 *  whether a further page is available on success, or `nil`/`NO` and an
 *  error on failure.
 */
- (void)fetchPopularMangaFromSourceId:(NSString *)sourceId
                              pageNum:(NSUInteger)pageNum
                           completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                                NSError *error))completion;

/**
 *  Fetches a page of a source's "latest manga" listing.
 *
 *  @param sourceId The server-assigned identifier of the source.
 *  @param pageNum The page number to fetch.
 *  @param completion Called with the page's array of `YGRManga` objects and
 *  whether a further page is available on success, or `nil`/`NO` and an
 *  error on failure.
 */
- (void)fetchLatestMangaFromSourceId:(NSString *)sourceId
                             pageNum:(NSUInteger)pageNum
                          completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                               NSError *error))completion;

/**
 *  Searches a source's manga catalog for a search term.
 *
 *  @param sourceId The server-assigned identifier of the source.
 *  @param searchTerm The text to search for; percent-escaped before being
 *  sent as a query parameter.
 *  @param pageNum The page number to fetch.
 *  @param completion Called with the page's array of `YGRManga` objects and
 *  whether a further page is available on success, or `nil`/`NO` and an
 *  error on failure.
 */
- (void)searchMangaInSourceId:(NSString *)sourceId
                   searchTerm:(NSString *)searchTerm
                      pageNum:(NSUInteger)pageNum
                   completion:
                       (void (^)(NSArray *mangaList, BOOL hasNextPage, NSError *error))completion;

@end
