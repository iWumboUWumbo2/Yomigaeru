//
//  YGRCategoryService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Fetches library categories and the manga assigned to them from the server.
 */
@interface YGRCategoryService : NSObject

#pragma mark - Public API

/**
 *  Fetches every category defined on the server.
 *
 *  @param completion Called with the array of `YGRCategory` objects on
 *  success, or `nil` and an error on failure.
 */
- (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *categories, NSError *error))completion;

/**
 *  Fetches the manga assigned to a given category.
 *
 *  @param categoryId The server-assigned identifier of the category.
 *  @param completion Called with the array of `YGRManga` objects on success,
 *  or `nil` and an error on failure.
 */
- (void)fetchMangasWithCategoryId:(NSString *)categoryId
                       completion:(void (^)(NSArray *mangas, NSError *error))completion;

/**
 *  Fetches the manga in the server's default/unsorted category (category id
 *  "0"), i.e. the user's overall library.
 *
 *  @param completion Called with the array of `YGRManga` objects on success,
 *  or `nil` and an error on failure.
 */
- (void)fetchLibraryWithCompletion:(void (^)(NSArray *mangas, NSError *error))completion;

@end
