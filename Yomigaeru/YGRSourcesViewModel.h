//
//  YGRSourcesViewModel.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRSource.h"

@interface YGRSourcesViewModel : NSObject

#pragma mark - Properties

/** The section (language) keys currently visible, reflecting any active search filter. */
@property (nonatomic, copy, readonly) NSArray *sections;

#pragma mark - Fetching

/**
 *  Fetches the full source list from the source service and rebuilds the
 *  sectioned data, reapplying the current search filter if one is active.
 *
 *  @param completion Called with an error if the fetch failed, or nil on success.
 */
- (void)refreshWithCompletion:(void (^)(NSError *error))completion;

#pragma mark - Table Helpers

/**
 *  Returns the number of rows to display in a given table section.
 *
 *  @param section The index of the section within `sections`.
 *
 *  @return The number of sources in that section.
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

/**
 *  Returns the source to display at a given table index path.
 *
 *  @param indexPath The index path of the row.
 *
 *  @return The source at that index path.
 */
- (YGRSource *)sourceAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Search

/**
 *  Filters the visible sections down to sources whose name starts with the
 *  given search term.
 *
 *  @param term The search term to filter source names by.
 */
- (void)searchWithTerm:(NSString *)term;

/**
 *  Clears any active search filter, restoring the full unfiltered section list.
 */
- (void)clearSearch;

@end
