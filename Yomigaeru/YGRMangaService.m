//
//  YGRMangaService.m
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRMangaService.h"
#import "YGRHttpStatus.h"
#import "YGRImageUtility.h"
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

- (void)fetchThumbnailWithMangaId:(NSString *)mangaId
                       completion:(void (^)(UIImage *thumbnailImage, NSError *error))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/thumbnail", mangaId];

    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:path parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation
        setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *contentType =
                [operation.response.allHeaderFields objectForKey:@"Content-Type"] ?: @"";

            NSError *decodeError = nil;
            UIImage *image = [YGRImageUtility imageFromData:(NSData *) responseObject
                                                   mimeType:contentType
                                                      error:&decodeError];

            if (!image)
            {
                completion(nil, decodeError);
                return;
            }

            completion(image, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];

    [httpClient enqueueHTTPRequestOperation:operation];
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

- (void)fetchChapterWithMangaId:(NSString *)mangaId
                   chapterIndex:(NSUInteger)chapterIndex
                     completion:(void (^)(YGRChapter *chapter, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/chapter/%tu", mangaId, chapterIndex];

    [jsonClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *jsonDict = (NSDictionary *) responseObject;
            YGRChapter *chapter = [[YGRChapter alloc] initWithDictionary:jsonDict];
            completion(chapter, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
                  completion:(void (^)(UIImage *pageData, NSError *error))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString
        stringWithFormat:@"manga/%@/chapter/%tu/page/%tu", mangaId, chapterIndex, pageIndex];

    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:path parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation
        setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *contentType =
                [operation.response.allHeaderFields objectForKey:@"Content-Type"] ?: @"";

            NSError *decodeError = nil;
            UIImage *image = [YGRImageUtility imageFromData:(NSData *) responseObject
                                                   mimeType:contentType
                                                      error:&decodeError];

            if (!image)
            {
                completion(nil, decodeError);
                return;
            }

            completion(image, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];

    [httpClient enqueueHTTPRequestOperation:operation];
}

@end
