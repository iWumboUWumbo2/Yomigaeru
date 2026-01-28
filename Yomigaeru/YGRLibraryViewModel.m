//
//  YGRLibraryViewModel.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRLibraryViewModel.h"
#import "YGRCategoryService.h"
#import "YGRMangaService.h"

@interface YGRLibraryViewModel ()

@property (nonatomic, strong) YGRCategoryService *categoryService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangaList;

@end

@implementation YGRLibraryViewModel

- (instancetype)init
{
    if (self = [super init])
    {
        _categoryService = [[YGRCategoryService alloc] init];
        _mangaService = [[YGRMangaService alloc] init];
        _mangaList = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public API

- (NSArray *)mangas
{
    return [self.mangaList copy];
}

- (NSUInteger)numberOfItems
{
    return self.mangaList.count;
}

- (YGRManga *)mangaAtIndex:(NSUInteger)index
{
    if (index >= self.mangaList.count)
    {
        return nil;
    }
    return self.mangaList[index];
}

#pragma mark - Fetching

- (void)fetchLibraryWithCompletion:(void (^)(NSError *error))completion
{
    __weak typeof(self) weakSelf = self;

    [self.categoryService fetchLibraryWithCompletion:^(NSArray *mangas, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (error)
        {
            completion(error);
            return;
        }

        strongSelf.mangaList = [NSMutableArray arrayWithArray:mangas];
        completion(nil);
    }];
}

#pragma mark - Library Management

- (void)deleteFromLibraryAtIndex:(NSUInteger)index
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    if (index >= self.mangaList.count)
    {
        completion(NO, nil);
        return;
    }

    YGRManga *manga = self.mangaList[index];

    __weak typeof(self) weakSelf = self;

    [self.mangaService deleteFromLibraryWithMangaId:manga.id_
                                         completion:^(BOOL success, NSError *error) {
                                             __strong typeof(weakSelf) strongSelf = weakSelf;

                                             if (error || !success)
                                             {
                                                 completion(NO, error);
                                                 return;
                                             }

                                             [strongSelf.mangaList removeObjectAtIndex:index];
                                             completion(YES, nil);
                                         }];
}

- (void)markReadAtIndex:(NSUInteger)index
             completion:(void (^)(BOOL success, NSError *error))completion
{
    if (index >= self.mangaList.count)
    {
        completion(NO, nil);
        return;
    }

    YGRManga *manga = self.mangaList[index];

    [self.mangaService markMangaReadStatusWithMangaId:manga.id_
                                           readStatus:YES
                                           completion:^(BOOL success, NSError *error) {
                                               if (error || !success)
                                               {
                                                   completion(NO, error);
                                                   return;
                                               }

                                               completion(YES, nil);
                                           }];
}

- (void)markUnreadAtIndex:(NSUInteger)index
               completion:(void (^)(BOOL success, NSError *error))completion
{
    if (index >= self.mangaList.count)
    {
        completion(NO, nil);
        return;
    }

    YGRManga *manga = self.mangaList[index];

    [self.mangaService markMangaReadStatusWithMangaId:manga.id_
                                           readStatus:NO
                                           completion:^(BOOL success, NSError *error) {
                                               if (error || !success)
                                               {
                                                   completion(NO, error);
                                                   return;
                                               }

                                               completion(YES, nil);
                                           }];
}

@end
