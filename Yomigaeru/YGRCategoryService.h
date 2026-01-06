//
//  YGRCategoryService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRCategoryService : NSObject

- (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *categories, NSError *error))completion;
- (void)fetchMangasWithCategoryId:(NSString *)categoryId
                       completion:(void (^)(NSArray *mangas, NSError *error))completion;
- (void)fetchLibraryWithCompletion:(void (^)(NSArray *mangas, NSError *error))completion;

@end
