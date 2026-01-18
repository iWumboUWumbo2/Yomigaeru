//
//  YGRMangaService.m
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRMangaService.h"
#import "YGRHttpStatus.h"
#import "YGRNetworkManager.h"

@implementation YGRMangaService

- (void)fetchMangaWithId:(NSString *)mangaId
              completion:(void (^)(YGRManga *manga, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@", mangaId];

    [jsonClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *jsonDict = (NSDictionary *) responseObject;
            YGRManga *manga = [[YGRManga alloc] initWithDictionary:jsonDict];
            completion(manga, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

- (void)fetchFullMangaWithId:(NSString *)mangaId
                  completion:(void (^)(YGRManga *manga, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/full", mangaId];

    [jsonClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *jsonDict = (NSDictionary *) responseObject;
            YGRManga *manga = [[YGRManga alloc] initWithDictionary:jsonDict];
            completion(manga, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

- (void)addToLibraryWithMangaId:(NSString *)mangaId
                     completion:(void (^)(BOOL success, NSError *error))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/library", mangaId];

    [httpClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) operation.response;
            BOOL success = httpResponse.statusCode == HttpStatusOK;
            completion(success, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO, error);
        }];
}

- (void)deleteFromLibraryWithMangaId:(NSString *)mangaId
                          completion:(void (^)(BOOL success, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/library", mangaId];

    [jsonClient deletePath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) operation.response;
            BOOL success = httpResponse.statusCode == HttpStatusOK;
            completion(success, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO, error);
        }];
}

- (void)fetchChaptersWithMangaId:(NSString *)mangaId
                      completion:(void (^)(NSArray *chapters, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/chapters", mangaId];

    [jsonClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *jsonArray = (NSArray *) responseObject;
            NSMutableArray *chapters = [NSMutableArray arrayWithCapacity:jsonArray.count];
            for (NSDictionary *dict in jsonArray)
            {
                [chapters addObject:[[YGRChapter alloc] initWithDictionary:dict]];
            }
            completion(chapters, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

- (void)modifyChapterWithMangaId:(NSString *)mangaId
                    chapterIndex:(NSUInteger)chapterIndex
                      parameters:(NSDictionary *)parameters
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    httpClient.parameterEncoding = AFFormURLParameterEncoding;
    [httpClient setDefaultHeader:@"Content-Type"
                           value:@"application/x-www-form-urlencoded"];
    
    NSString *path = [NSString stringWithFormat:@"manga/%@/chapter/%tu", mangaId, chapterIndex];
    
    [httpClient putPath:path
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) operation.response;
                      BOOL success = httpResponse.statusCode == HttpStatusOK;
                      completion(success, nil);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      completion(NO, error);
                  }];
}

static inline NSString *NSStringFromBool(BOOL value) {
    return value ? @"true" : @"false";
}

- (void)markReadStatusChapterWithMangaId:(NSString *)mangaId
                            chapterIndex:(NSUInteger)chapterIndex
                              readStatus:(BOOL)readStatus
                              completion:(void (^)(BOOL success, NSError *error))completion
{
    [self modifyChapterWithMangaId:mangaId chapterIndex:chapterIndex parameters:@{@"read": NSStringFromBool(readStatus)} completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

- (void)markBookmarkStatusChapterWithMangaId:(NSString *)mangaId
                                chapterIndex:(NSUInteger)chapterIndex
                              bookmarkStatus:(BOOL)bookmarkStatus
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    [self modifyChapterWithMangaId:mangaId chapterIndex:chapterIndex parameters:@{@"bookmarked": NSStringFromBool(bookmarkStatus)} completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

- (void)markPrevReadStatusChapterWithMangaId:(NSString *)mangaId
                                chapterIndex:(NSUInteger)chapterIndex
                          markPrevReadStatus:(BOOL)markPrevReadStatus
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    [self modifyChapterWithMangaId:mangaId chapterIndex:chapterIndex parameters:@{@"markPrevRead": NSStringFromBool(markPrevReadStatus)} completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

- (void)markLastPageReadForChapterWithMangaId:(NSString *)mangaId
                                 chapterIndex:(NSUInteger)chapterIndex
                                 lastPageRead:(NSUInteger)lastPageRead
                                   completion:(void (^)(BOOL success, NSError *error))completion
{
    [self modifyChapterWithMangaId:mangaId chapterIndex:chapterIndex parameters:@{@"lastPageRead": @(lastPageRead)} completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

- (void)markMangaReadStatusWithMangaId:(NSString *)mangaId
                            readStatus:(BOOL)readStatus
                            completion:(void (^)(BOOL success, NSError *error))completion
{
    [self fetchFullMangaWithId:mangaId completion:^(YGRManga *manga, NSError *error) {
        if (error)
        {
            completion(NO, error);
            return;
        }
        
        NSString *readStatusString = NSStringFromBool(readStatus);
        
        [self modifyChapterWithMangaId:mangaId chapterIndex:manga.chapterCount parameters:@{@"read": readStatusString, @"markPrevRead": readStatusString} completion:^(BOOL success, NSError *error) {
            completion(success, error);
        }];
    }];
}

@end
