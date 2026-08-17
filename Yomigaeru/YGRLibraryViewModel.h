//
//  YGRLibraryViewModel.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRManga.h"

@interface YGRLibraryViewModel : NSObject

#pragma mark - Properties

/** The manga currently held in the user's library, in fetch order. */
@property (nonatomic, readonly) NSArray *mangas;

#pragma mark - Fetching

/**
 *  Fetches the user's library from the category service and replaces the
 *  local manga list with the result.
 *
 *  @param completion Called with an error if the fetch failed, or nil on success.
 */
- (void)fetchLibraryWithCompletion:(void (^)(NSError *error))completion;

#pragma mark - Grid Helpers

/**
 *  @return The number of manga currently in the library.
 */
- (NSUInteger)numberOfItems;

/**
 *  Returns the manga to display at a given grid index.
 *
 *  @param index The index of the manga within the library.
 *
 *  @return The manga at that index, or nil if `index` is out of bounds.
 */
- (YGRManga *)mangaAtIndex:(NSUInteger)index;

#pragma mark - Library Management

/**
 *  Removes the manga at the given index from the library via the manga
 *  service, and removes it from the local list on success.
 *
 *  @param index The index of the manga to remove.
 *  @param completion Called with the outcome; `success` is NO (with `error`
 *                     left nil) when `index` is out of bounds.
 */
- (void)deleteFromLibraryAtIndex:(NSUInteger)index
                      completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Marks the manga at the given index as read via the manga service.
 *
 *  @param index The index of the manga to update.
 *  @param completion Called with the outcome; `success` is NO (with `error`
 *                     left nil) when `index` is out of bounds.
 */
- (void)markReadAtIndex:(NSUInteger)index
             completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Marks the manga at the given index as unread via the manga service.
 *
 *  @param index The index of the manga to update.
 *  @param completion Called with the outcome; `success` is NO (with `error`
 *                     left nil) when `index` is out of bounds.
 */
- (void)markUnreadAtIndex:(NSUInteger)index
               completion:(void (^)(BOOL success, NSError *error))completion;

@end
