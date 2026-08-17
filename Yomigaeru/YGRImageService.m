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

/**
 *  The maximum size, in pixels, a decoded page image's larger dimension is
 *  downsampled to. Roughly 2x the iPad 1's largest screen dimension (1024pt
 *  @1x), which leaves headroom for the reader's pinch-zoom before the image
 *  looks soft, while keeping a single decoded page well under 20MB instead of
 *  the tens of MB an un-downsampled full-resolution scan can cost.
 */
static const CGFloat kYGRPageImageMaxDimension = 2048.0f;

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
        _thumbnailCache.countLimit = 200; // bound long library-browsing sessions

        _pageCache = [[NSCache alloc] init];
        _pageCache.totalCostLimit = 60 * 1024 * 1024; // 60 MB
        _pageCache.countLimit = 12; // backstop independent of prefetch settings
        _pageCache.name = @"YGRPageCache";

        // NSCache doesn't reliably self-purge under memory pressure on this
        // era of iOS, so purge both caches explicitly on memory warnings.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(didReceiveMemoryWarning)
                                                      name:UIApplicationDidReceiveMemoryWarningNotification
                                                    object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Thumbnails

/**
 *  Computes the thumbnail image size for the current device/idiom, sized to
 *  fit a 2-column (iPhone) or 4-column (iPad) grid at a 1.25 aspect ratio.
 *
 *  @return The target thumbnail size, in points.
 */
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
                    priority:(NSOperationQueuePriority)priority
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

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation
        setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *contentType = operation.response.allHeaderFields[@"Content-Type"] ?: @"";

            NSError *decodeError = nil;
            UIImage *image = [YGRImageUtility imageFromData:(NSData *) responseObject
                                                    mimeType:contentType
                                                 targetWidth:kYGRPageImageMaxDimension
                                                       error:&decodeError];

            if (!image)
            {
                completion(nil, decodeError);
                return;
            }

            NSUInteger cost = image.size.width * image.size.height * 4;
            [self.pageCache setObject:image forKey:cacheKey cost:cost];

            completion(image, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];

    operation.queuePriority = priority;
    [imageClient enqueueHTTPRequestOperation:operation];
}

#pragma mark - Memory Management

/**
 *  Empties both the thumbnail and page caches to free up memory.
 */
- (void)didReceiveMemoryWarning
{
    [self.thumbnailCache removeAllObjects];
    [self.pageCache removeAllObjects];
}

@end
