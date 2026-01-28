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

typedef NS_ENUM(NSInteger, YGRSourceLibraryListType) {
    YGRSourceLibraryListTypePopular = 0,
    YGRSourceLibraryListTypeLatest = 1
};

@interface YGRSourceLibraryViewModel : NSObject

@property (nonatomic, strong) YGRSource *source;
@property (nonatomic, readonly) NSArray *mangas;
@property (nonatomic, readonly) BOOL isLoading;

- (void)fetchMangaListOfType:(YGRSourceLibraryListType)listType
                  completion:(void (^)(NSError *error))completion;

- (void)searchMangaWithTerm:(NSString *)term
                 completion:(void (^)(NSError *error))completion;

- (void)loadNextPageWithCompletion:(void (^)(NSError *error))completion;

- (void)resetPagination;

- (BOOL)hasNextPage;

// Grid helpers
- (NSUInteger)numberOfItems;
- (YGRManga *)mangaAtIndex:(NSUInteger)index;

// Library management
- (void)toggleLibraryStatusAtIndex:(NSUInteger)index
                        completion:(void (^)(BOOL success, NSError *error))completion;

@end
