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

@property (nonatomic, readonly) NSArray *mangas;

- (void)fetchLibraryWithCompletion:(void (^)(NSError *error))completion;

// Grid helpers
- (NSUInteger)numberOfItems;
- (YGRManga *)mangaAtIndex:(NSUInteger)index;

// Library management
- (void)deleteFromLibraryAtIndex:(NSUInteger)index
                      completion:(void (^)(BOOL success, NSError *error))completion;

- (void)markReadAtIndex:(NSUInteger)index
             completion:(void (^)(BOOL success, NSError *error))completion;

- (void)markUnreadAtIndex:(NSUInteger)index
               completion:(void (^)(BOOL success, NSError *error))completion;

@end
