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
 *  The width, in pixels, page images are downsampled to before caching: the
 *  device's actual screen size, so a page is decoded at exactly the width the
 *  reader displays it at (see YGRPageViewController's width-fit scaling) and
 *  never needs to be upscaled to fill the screen — which is what was making
 *  text illegible. Uses the larger of the screen's two dimensions so quality
 *  doesn't depend on which orientation happened to be active when this ran.
 *
 *  @return The target width, in pixels, for decoded page images.
 */
static CGFloat YGRPageImageTargetWidth(void)
{
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat maxScreenDimension = MAX(screen.bounds.size.width, screen.bounds.size.height);
    return maxScreenDimension * screen.scale;
}

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
            NSData *data = (NSData *) responseObject;

            // AFHTTPRequestOperation calls success/failure blocks on the main
            // queue by default (successCallbackQueue is never set here), so
            // decoding has to be bounced onto a background queue explicitly —
            // otherwise this synchronous decode blocks the main thread, and
            // with it all touch handling, for as long as it takes.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *decodeError = nil;
                UIImage *image = [YGRImageUtility imageFromData:data
                                                       mimeType:contentType
                                                    targetWidth:[self thumbnailSize].width / 2
                                                          error:&decodeError];

                if (!image)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, decodeError);
                    });
                    return;
                }

                [self.thumbnailCache setObject:image forKey:cacheKey];

                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, nil);
                });
            });
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

    NSLog(@"[YGR-DEBUG] ImageService fetchPage START key=%@ thread=%@", cacheKey,
          [NSThread isMainThread] ? @"main" : @"bg");

    UIImage *cachedPage = [self.pageCache objectForKey:cacheKey];
    if (cachedPage)
    {
        NSLog(@"[YGR-DEBUG] ImageService fetchPage CACHE HIT key=%@ image=%@", cacheKey,
              cachedPage);
        completion(cachedPage, nil);
        return;
    }

    AFHTTPClient *imageClient = [[YGRNetworkManager sharedManager] imageClientInstance];

    NSString *path = [NSString
        stringWithFormat:@"manga/%@/chapter/%tu/page/%tu", mangaId, chapterIndex, pageIndex];

    NSLog(@"[YGR-DEBUG] ImageService fetchPage CACHE MISS key=%@ requesting path=%@ "
          @"imageClient=%@ baseURL=%@",
          cacheKey, path, imageClient, imageClient.baseURL);

    NSURLRequest *request = [imageClient requestWithMethod:@"GET" path:path parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation
        setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *contentType = operation.response.allHeaderFields[@"Content-Type"] ?: @"";
            NSData *data = (NSData *) responseObject;

            NSLog(@"[YGR-DEBUG] ImageService fetchPage HTTP SUCCESS key=%@ status=%ld "
                  @"contentType=%@ bytes=%lu thread=%@",
                  cacheKey, (long) operation.response.statusCode, contentType,
                  (unsigned long) data.length, [NSThread isMainThread] ? @"main" : @"bg");

            // AFHTTPRequestOperation calls success/failure blocks on the main
            // queue by default (successCallbackQueue is never set here), so
            // decoding has to be bounced onto a background queue explicitly —
            // otherwise this synchronous decode of a full page image blocks
            // the main thread, and with it all touch handling, for as long
            // as it takes (worst on the largest/slowest-to-decode pages).
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"[YGR-DEBUG] ImageService fetchPage DECODE START key=%@ thread=%@",
                      cacheKey, [NSThread isMainThread] ? @"main" : @"bg");

                NSError *decodeError = nil;
                UIImage *image = [YGRImageUtility imageFromData:data
                                                        mimeType:contentType
                                                     targetWidth:YGRPageImageTargetWidth()
                                                           error:&decodeError];

                NSLog(@"[YGR-DEBUG] ImageService fetchPage DECODE END key=%@ image=%@ size=%@ "
                      @"error=%@",
                      cacheKey, image, NSStringFromCGSize(image.size), decodeError);

                if (!image)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, decodeError);
                    });
                    return;
                }

                NSUInteger cost = image.size.width * image.size.height * 4;
                [self.pageCache setObject:image forKey:cacheKey cost:cost];

                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"[YGR-DEBUG] ImageService fetchPage calling completion() on main "
                          @"key=%@",
                          cacheKey);
                    completion(image, nil);
                });
            });
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[YGR-DEBUG] ImageService fetchPage HTTP FAILURE key=%@ status=%ld error=%@",
                  cacheKey, (long) operation.response.statusCode, error);
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
