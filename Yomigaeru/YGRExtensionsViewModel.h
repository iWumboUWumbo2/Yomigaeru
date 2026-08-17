//
//  YGRExtensionsViewModel.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRExtension.h"

/** The section title used to group extensions that have an update available. */
extern NSString *const kExtensionUpdatesPendingKey;
/** The section title used to group extensions that are already installed. */
extern NSString *const kExtensionInstalledKey;

@interface YGRExtensionsViewModel : NSObject

#pragma mark - Properties

/** The section (language, or one of the special keys above) keys currently visible, reflecting any active search filter. */
@property (nonatomic, copy, readonly) NSArray *sections;

#pragma mark - Fetching

/**
 *  Fetches the full extension list from the extension service and rebuilds
 *  the sectioned data, reapplying the current search filter if one is active.
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
 *  @return The number of extensions in that section.
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

/**
 *  Returns the extension to display at a given table index path.
 *
 *  @param indexPath The index path of the row.
 *
 *  @return The extension at that index path.
 */
- (YGRExtension *)extensionAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Search

/**
 *  Filters the visible sections down to extensions whose name starts with
 *  the given search term.
 *
 *  @param term The search term to filter extension names by.
 */
- (void)searchWithTerm:(NSString *)term;

/**
 *  Clears any active search filter, restoring the full unfiltered section list.
 */
- (void)clearSearch;

#pragma mark - Actions

/**
 *  Installs the given extension via the extension service.
 *
 *  @param extension The extension to install.
 *  @param completion Called with an error if the install failed, or nil on success.
 */
- (void)installExtension:(YGRExtension *)extension completion:(void (^)(NSError *error))completion;

/**
 *  Uninstalls the given extension via the extension service.
 *
 *  @param extension The extension to remove.
 *  @param completion Called with an error if the removal failed, or nil on success.
 */
- (void)removeExtension:(YGRExtension *)extension completion:(void (^)(NSError *error))completion;

/**
 *  Updates the given extension to its latest available version via the
 *  extension service.
 *
 *  @param extension The extension to update.
 *  @param completion Called with an error if the update failed, or nil on success.
 */
- (void)updateExtension:(YGRExtension *)extension completion:(void (^)(NSError *error))completion;

@end
