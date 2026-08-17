//
//  YGRSourceLibraryViewModel.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourceLibraryViewModel.h"
#import "YGRSourceService.h"
#import "YGRMangaService.h"

@interface YGRSourceLibraryViewModel ()

@property (nonatomic, strong) YGRSourceService *sourceService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangaList;
@property (nonatomic, assign) BOOL hasNextPageFlag;
@property (nonatomic, assign) BOOL isLoadingPage;

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) YGRSourceLibraryListType currentListType;
@property (nonatomic, copy) NSString *currentSearchTerm;

@end

@implementation YGRSourceLibraryViewModel

- (instancetype)init
{
    if (self = [super init])
    {
        _sourceService = [[YGRSourceService alloc] init];
        _mangaService = [[YGRMangaService alloc] init];
        _mangaList = [NSMutableArray array];
        _currentPage = 1;
        _currentListType = YGRSourceLibraryListTypePopular;
    }
    return self;
}

#pragma mark - Public API

- (NSArray *)mangas
{
    return [self.mangaList copy];
}

- (BOOL)isLoading
{
    return self.isLoadingPage;
}

- (BOOL)hasNextPage
{
    return self.hasNextPageFlag;
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

#pragma mark - Pagination

- (void)resetPagination
{
    self.currentPage = 1;
    [self.mangaList removeAllObjects];
    self.currentSearchTerm = nil;
}

#pragma mark - Fetching

- (void)fetchMangaListOfType:(YGRSourceLibraryListType)listType
                  completion:(void (^)(NSError *error))completion
{
    self.currentListType = listType;
    self.currentSearchTerm = nil;

    switch (listType)
    {
    case YGRSourceLibraryListTypePopular:
        [self fetchPopularMangaWithCompletion:completion];
        break;

    case YGRSourceLibraryListTypeLatest:
        [self fetchLatestMangaWithCompletion:completion];
        break;
    }
}

- (void)searchMangaWithTerm:(NSString *)term
                 completion:(void (^)(NSError *error))completion
{
    self.currentSearchTerm = term;
    self.isLoadingPage = YES;

    __weak typeof(self) weakSelf = self;

    [self.sourceService searchMangaInSourceId:self.source.id_
                                   searchTerm:term
                                      pageNum:self.currentPage
                                   completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
                                       __strong typeof(weakSelf) strongSelf = weakSelf;
                                       if (!strongSelf) return;

                                       [strongSelf handleMangaListResult:mangaList
                                                              hasNextPage:hasNextPage
                                                                    error:error
                                                               completion:completion];
                                   }];
}

- (void)loadNextPageWithCompletion:(void (^)(NSError *error))completion
{
    if (!self.hasNextPageFlag || self.isLoadingPage)
    {
        return;
    }

    self.currentPage++;

    if (self.currentSearchTerm.length > 0)
    {
        [self searchMangaWithTerm:self.currentSearchTerm completion:completion];
    }
    else
    {
        [self fetchMangaListOfType:self.currentListType completion:completion];
    }
}

#pragma mark - Private Fetching

/**
 *  Fetches the current page of the source's popular manga list and appends
 *  the results to `mangaList`, updating pagination state.
 *
 *  @param completion Called with an error if the fetch failed, or nil on success.
 */
- (void)fetchPopularMangaWithCompletion:(void (^)(NSError *error))completion
{
    self.isLoadingPage = YES;

    __weak typeof(self) weakSelf = self;

    [self.sourceService
        fetchPopularMangaFromSourceId:self.source.id_
                              pageNum:self.currentPage
                           completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               if (!strongSelf) return;

                               [strongSelf handleMangaListResult:mangaList
                                                      hasNextPage:hasNextPage
                                                            error:error
                                                       completion:completion];
                           }];
}

/**
 *  Fetches the current page of the source's latest manga list and appends
 *  the results to `mangaList`, updating pagination state.
 *
 *  @param completion Called with an error if the fetch failed, or nil on success.
 */
- (void)fetchLatestMangaWithCompletion:(void (^)(NSError *error))completion
{
    self.isLoadingPage = YES;

    __weak typeof(self) weakSelf = self;

    [self.sourceService
        fetchLatestMangaFromSourceId:self.source.id_
                             pageNum:self.currentPage
                          completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              if (!strongSelf) return;

                              [strongSelf handleMangaListResult:mangaList
                                                     hasNextPage:hasNextPage
                                                           error:error
                                                      completion:completion];
                          }];
}

- (void)handleMangaListResult:(NSArray *)mangaList
                   hasNextPage:(BOOL)hasNextPage
                         error:(NSError *)error
                    completion:(void (^)(NSError *error))completion
{
    self.isLoadingPage = NO;

    if (error)
    {
        completion(error);
        return;
    }

    [self.mangaList addObjectsFromArray:mangaList];
    self.hasNextPageFlag = hasNextPage;

    completion(nil);
}

#pragma mark - Library Management

- (void)toggleLibraryStatusAtIndex:(NSUInteger)index
                        completion:(void (^)(BOOL success, NSError *error))completion
{
    if (index >= self.mangaList.count)
    {
        completion(NO, nil);
        return;
    }

    YGRManga *manga = self.mangaList[index];

    __weak typeof(self) weakSelf = self;

    if (!manga.inLibrary)
    {
        [self.mangaService addToLibraryWithMangaId:manga.id_
                                        completion:^(BOOL success, NSError *error) {
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            if (!strongSelf) return;

                                            [strongSelf handleLibraryToggleSuccess:success
                                                                              error:error
                                                                            atIndex:index
                                                                          inLibrary:YES
                                                                         completion:completion];
                                        }];
    }
    else
    {
        [self.mangaService deleteFromLibraryWithMangaId:manga.id_
                                             completion:^(BOOL success, NSError *error) {
                                                 __strong typeof(weakSelf) strongSelf = weakSelf;
                                                 if (!strongSelf) return;

                                                 [strongSelf handleLibraryToggleSuccess:success
                                                                                   error:error
                                                                                 atIndex:index
                                                                               inLibrary:NO
                                                                              completion:completion];
                                             }];
    }
}

- (void)handleLibraryToggleSuccess:(BOOL)success
                              error:(NSError *)error
                            atIndex:(NSUInteger)index
                          inLibrary:(BOOL)inLibrary
                         completion:(void (^)(BOOL success, NSError *error))completion
{
    if (error || !success)
    {
        completion(NO, error);
        return;
    }

    YGRManga *m = self.mangaList[index];
    m.inLibrary = inLibrary;
    completion(YES, nil);
}

@end
