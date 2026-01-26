//
//  YGRImageService.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/17.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRImageService.h"
#import "YGRChapter.h"
#import "YGRImageUtility.h"
#import "YGRNetworkManager.h"

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
        _pageCache.totalCostLimit = 50 * 1024 * 1024; // 50 MB
        _pageCache.name = @"YGRPageCache";
    }
    return self;
}

#pragma mark - Thumbnails

- (CGSize)thumbnailSize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;

    int columnCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 2;
    CGFloat cellWidth = screenWidth / columnCount;

    return CGSizeMake(cellWidth, cellWidth * 1.25);
}

- (void)fetchThumbnailWithMangaId:(NSString *)mangaId
                       completion:(void (^)(UIImage *thumbnailImage, NSError *error))completion
{
    if (!completion)
        return;
    //    //
    //    completion([UIImage imageNamed:@"placeholder"], nil);
    //    return;
    //    //

    NSString *cacheKey = [NSString stringWithFormat:@"thumb:%@", mangaId];
    UIImage *cachedThumbnail = [self.thumbnailCache objectForKey:cacheKey];
    if (cachedThumbnail)
    {
        completion(cachedThumbnail, nil);
        return;
    }

    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString stringWithFormat:@"manga/%@/thumbnail", mangaId];

    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:path parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation
        setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *contentType = operation.response.allHeaderFields[@"Content-Type"] ?: @"";

            NSError *decodeError = nil;
            UIImage *image = [YGRImageUtility imageFromData:(NSData *) responseObject
                                                   mimeType:contentType
                                                targetWidth:[self thumbnailSize].width / 2
                                                      error:&decodeError];

            if (!image)
            {
                completion(nil, decodeError);
                return;
            }

            [self.thumbnailCache setObject:image forKey:cacheKey];
            completion(image, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];

    [httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark - Pages

- (void)fetchPageWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSUInteger)pageIndex
                  completion:(void (^)(UIImage *pageData, NSError *error))completion
{
    if (!completion)
        return;

    NSString *cacheKey =
        [NSString stringWithFormat:@"page:%@:%tu:%tu", mangaId, chapterIndex, pageIndex];

    UIImage *cachedPage = [self.pageCache objectForKey:cacheKey];
    if (cachedPage)
    {
        completion(cachedPage, nil);
        return;
    }

    AFHTTPClient *imageClient = [[YGRNetworkManager sharedManager] imageClientInstance];

    NSString *path = [NSString
        stringWithFormat:@"manga/%@/chapter/%tu/page/%tu", mangaId, chapterIndex, pageIndex];

    NSURLRequest *request = [imageClient requestWithMethod:@"GET" path:path parameters:nil];

    AFImageRequestOperation *operation =
        [AFImageRequestOperation imageRequestOperationWithRequest:request
            imageProcessingBlock:^UIImage *(UIImage *image) {
                return image;
            }
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                NSUInteger cost = image.size.width * image.size.height * 4;

                [self.pageCache setObject:image forKey:cacheKey cost:cost];

                completion(image, nil);
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                completion(nil, error);
            }];

    [imageClient enqueueHTTPRequestOperation:operation];
}

- (void)didReceiveMemoryWarning
{
    [self.thumbnailCache removeAllObjects];
    [self.pageCache removeAllObjects];
}

@end
