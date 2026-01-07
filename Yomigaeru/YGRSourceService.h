//
//  YGRSourceService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRSource.h"
#import <Foundation/Foundation.h>

@interface YGRSourceService : NSObject

- (void)fetchAllSourcesWithCompletion:(void (^)(NSArray *sources, NSError *error))completion;
- (void)fetchSourceWithId:(NSString *)sourceId
               completion:(void (^)(YGRSource *source, NSError *error))completion;
- (void)fetchPopularMangaFromSourceId:(NSString *)sourceId
                              pageNum:(NSUInteger)pageNum
                           completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                                NSError *error))completion;
- (void)fetchLatestMangaFromSourceId:(NSString *)sourceId
                             pageNum:(NSUInteger)pageNum
                          completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                               NSError *error))completion;
- (void)searchMangaInSourceId:(NSString *)sourceId
                   searchTerm:(NSString *)searchTerm
                      pageNum:(NSUInteger)pageNum
                   completion:
                       (void (^)(NSArray *mangaList, BOOL hasNextPage, NSError *error))completion;

@end
