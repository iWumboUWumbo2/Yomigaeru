//
//  YGRSourceLibraryViewModel.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRSource.h"
#import "YGRManga.h"

/** Which list of manga to fetch from a source. */
typedef NS_ENUM(NSInteger, YGRSourceLibraryListType) {
    YGRSourceLibraryListTypePopular = 0,
    YGRSourceLibraryListTypeLatest = 1
};

@interface YGRSourceLibraryViewModel : NSObject

#pragma mark - Properties

/** The source being browsed. */
@property (nonatomic, strong) YGRSource *source;
/** The manga fetched so far, across all loaded pages. */
@property (nonatomic, readonly) NSArray *mangas;
/** Whether a page fetch (initial, search, or next-page) is currently in flight. */
@property (nonatomic, readonly) BOOL isLoading;

#pragma mark - Fetching

/**
 *  Fetches the first page of the given list type from the source, replacing
 *  any previously loaded manga.
 *
 *  @param listType The list to fetch (popular or latest).
 *  @param completion Called with an error if the fetch failed, or nil on success.
 */
- (void)fetchMangaListOfType:(YGRSourceLibraryListType)listType
                  completion:(void (^)(NSError *error))completion;

/**
 *  Searches the source for manga matching the given term, appending the
 *  results to the current page of manga.
 *
 *  @param term The search term to query the source with.
 *  @param completion Called with an error if the search failed, or nil on success.
 */
- (void)searchMangaWithTerm:(NSString *)term
                 completion:(void (^)(NSError *error))completion;

/**
 *  Loads the next page of results for the current search term (or, if no
 *  search is active, the current list type), appending to the existing
 *  manga list. Does nothing if there is no next page or a page is already
 *  loading.
 *
 *  @param completion Called with an error if the fetch failed, or nil on success.
 */
- (void)loadNextPageWithCompletion:(void (^)(NSError *error))completion;

/**
 *  Resets pagination state back to the first page, clears the loaded manga
 *  list, and clears the current search term.
 */
- (void)resetPagination;

/**
 *  @return YES if another page of results is available to load, NO otherwise.
 */
- (BOOL)hasNextPage;

#pragma mark - Grid Helpers

/**
 *  @return The number of manga currently loaded.
 */
- (NSUInteger)numberOfItems;

/**
 *  Returns the manga to display at a given grid index.
 *
 *  @param index The index of the manga within the loaded list.
 *
 *  @return The manga at that index, or nil if `index` is out of bounds.
 */
- (YGRManga *)mangaAtIndex:(NSUInteger)index;

#pragma mark - Library Management

/**
 *  Adds or removes the manga at the given index from the user's library,
 *  depending on its current `inLibrary` state, and updates that state on
 *  success.
 *
 *  @param index The index of the manga to toggle.
 *  @param completion Called with the outcome; `success` is NO (with `error`
 *                     left nil) when `index` is out of bounds.
 */
- (void)toggleLibraryStatusAtIndex:(NSUInteger)index
                        completion:(void (^)(BOOL success, NSError *error))completion;

@end
