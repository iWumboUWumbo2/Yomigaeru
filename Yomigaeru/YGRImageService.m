//
//  YGRImageService.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/17.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRImageService.h"
#import "YGRNetworkManager.h"
#import "YGRImageUtility.h"
#import "YGRChapter.h"

@interface YGRImageService ()

@property (nonatomic, strong) NSCache *thumbnailCache;
@property (nonatomic, strong) NSCache *pageCache;

@end

@implementation YGRImageService

#pragma mark - Singleton

+ (instancetype)sharedService
{
    static YGRImageService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _thumbnailCache = [[NSCache alloc] init];
        _thumbnailCache.name = @"YGRThumbnailCache";
        
        _pageCache = [[NSCache alloc] init];
        _pageCache.name = @"YGRPageCache";
    }
    return self;
}

#pragma mark - Thumbnails

- (void)fetchThumbnailWithMangaId:(NSString *)mangaId
                       completion:(void (^)(UIImage *thumbnailImage, NSError *error))completion
{
    if (!completion) return;
    
    NSString *cacheKey = [NSString stringWithFormat:@"thumb:%@", mangaId];
    UIImage *cachedThumbnail = [self.thumbnailCache objectForKey:cacheKey];
    if (cachedThumbnail)
    {
        completion(cachedThumbnail, nil);
        return;
    }
    
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/thumbnail", mangaId];
    
    NSURLRequest *request =
    [httpClient requestWithMethod:@"GET" path:path parameters:nil];
    
    AFHTTPRequestOperation *operation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *contentType =
        operation.response.allHeaderFields[@"Content-Type"] ?: @"";
        
        NSError *decodeError = nil;
        UIImage *image =
        [YGRImageUtility imageFromData:(NSData *)responseObject
                              mimeType:contentType
                                 error:&decodeError];
        
        if (!image)
        {
            completion(nil, decodeError);
            return;
        }
        
        [self.thumbnailCache setObject:image forKey:cacheKey];
        completion(image, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        completion(nil, error);
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark - Chapters

- (void)fetchChapterWithMangaId:(NSString *)mangaId
                   chapterIndex:(NSUInteger)chapterIndex
                     completion:(void (^)(YGRChapter *chapter, NSError *error))completion
{
    if (!completion) return;
    
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path =
    [NSString stringWithFormat:@"manga/%@/chapter/%tu", mangaId, chapterIndex];
    
    [jsonClient getPath:path
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSDictionary *jsonDict = (NSDictionary *)responseObject;
                    YGRChapter *chapter =
                    [[YGRChapter alloc] initWithDictionary:jsonDict];
                    
                    completion(chapter, nil);
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    completion(nil, error);
                }];
}

#pragma mark - Pages (Internal)

- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
           didRefreshChapter:(BOOL)didRefreshChapter
                  completion:(void (^)(UIImage *pageData, NSError *error))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path =
    [NSString stringWithFormat:@"manga/%@/chapter/%tu/page/%tu",
     mangaId, chapterIndex, pageIndex];
    
    NSURLRequest *request =
    [httpClient requestWithMethod:@"GET" path:path parameters:nil];
    
    AFHTTPRequestOperation *operation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *contentType =
        operation.response.allHeaderFields[@"Content-Type"] ?: @"";
        
        NSError *decodeError = nil;
        UIImage *image =
        [YGRImageUtility imageFromData:(NSData *)responseObject
                              mimeType:contentType
                                 error:&decodeError];
        
        if (!image)
        {
            completion(nil, decodeError);
            return;
        }
        
        completion(image, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (didRefreshChapter)
        {
            completion(nil, error);
            return;
        }
        
        [self fetchChapterWithMangaId:mangaId
                         chapterIndex:chapterIndex
                           completion:^(YGRChapter *chapter, NSError *chapterError) {
                               
                               if (chapterError)
                               {
                                   completion(nil, error);
                                   return;
                               }
                               
                               [self fetchPageWithMangaId:mangaId
                                             chapterIndex:chapterIndex
                                                pageIndex:pageIndex
                                        didRefreshChapter:YES
                                               completion:completion];
                           }];
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark - Pages (Public)

- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
                  completion:(void (^)(UIImage *pageData, NSError *error))completion
{
    if (!completion) return;
    
    NSString *cacheKey =
    [NSString stringWithFormat:@"page:%@:%tu:%tu",
     mangaId, chapterIndex, pageIndex];
    
    UIImage *cachedPage = [self.pageCache objectForKey:cacheKey];
    if (cachedPage)
    {
        completion(cachedPage, nil);
        return;
    }
        
    [self fetchPageWithMangaId:mangaId
                  chapterIndex:chapterIndex
                     pageIndex:pageIndex
             didRefreshChapter:NO
                    completion:^(UIImage *pageData, NSError *error) {
                        
                        if (error)
                        {
                            completion(nil, error);
                            return;
                        }
                        
                        [self.pageCache setObject:pageData forKey:cacheKey];
                        completion(pageData, nil);
                    }];
}

@end
