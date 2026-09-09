//
//  YGRPageView.m
//  Yomigaeru
//
//  Created by John Connery on 9/4/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import "YGRPageView.h"

#import "YGRImageService.h"
#import "YGRMangaService.h"

@interface YGRPageView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, assign) NSUInteger loadGeneration;

@end

@implementation YGRPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configurePageView];
    }
    return self;
}

/**
 *  Builds the zoomable scroll view, image view, and loading spinner used to
 *  display the page.
 */
- (void)configurePageView
{
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.scrollView addSubview:self.imageView];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.hidesWhenStopped = YES;
    [self addSubview:self.loadingSpinner];

    _doubleTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:_doubleTapGestureRecognizer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.loadingSpinner.center = CGPointMake(self.bounds.size.width / 2.0f,
                                             self.bounds.size.height / 2.0f);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerImageView];
}

#pragma mark - Double-Tap Zoom

/**
 *  Toggles between the minimum and maximum zoom scale, zooming in centered
 *  on the tapped point when zooming in.
 */
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        return;
    }

    CGFloat zoomScale = self.scrollView.maximumZoomScale;
    CGPoint tapPoint = [recognizer locationInView:self.imageView];

    CGFloat width = self.scrollView.bounds.size.width / zoomScale;
    CGFloat height = self.scrollView.bounds.size.height / zoomScale;

    CGRect zoomRect = CGRectMake(tapPoint.x - width / 2.0f,
                                  tapPoint.y - height / 2.0f,
                                  width,
                                  height);

    [self.scrollView zoomToRect:zoomRect animated:YES];
}

/**
 *  Keeps the image view centered within the scroll view's bounds as the
 *  zoom level changes. Needed because zooming a plain UIView (rather than
 *  a container view wrapping it) rescales that view's own frame in place;
 *  a letterboxed page (one shorter than the screen after being scaled to
 *  fit width) would otherwise drift toward the content area's top-left
 *  origin as soon as zoomScale moved off 1.0, since that frame's origin —
 *  not wherever it visually appeared before zooming started — is what the
 *  zoom transform actually scales around.
 */
- (void)centerImageView
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frame = self.imageView.frame;

    frame.origin.x = (frame.size.width < boundsSize.width)
        ? (boundsSize.width - frame.size.width) / 2.0f
        : 0.0f;

    frame.origin.y = (frame.size.height < boundsSize.height)
        ? (boundsSize.height - frame.size.height) / 2.0f
        : 0.0f;

    self.imageView.frame = frame;
}

#pragma mark - Page Loading

/**
 *  Displays the given image, scaling it to fill the scroll view's width
 *  while preserving aspect ratio, resetting the zoom level, and centering
 *  the image vertically if it's shorter than the screen.
 *
 *  @param image The page image to display.
 */
- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    CGSize imageSize = image.size;
    CGSize scrollSize = self.scrollView.bounds.size;
    
    // Scale so image width matches screen width
    CGFloat scale = scrollSize.width / imageSize.width;
    
    CGFloat width = scrollSize.width;
    CGFloat height = imageSize.height * scale;
    
    self.imageView.frame = CGRectMake(0, 0, width, height);
    self.scrollView.contentSize = CGSizeMake(width, height);

    // Reset zoom
    self.scrollView.zoomScale = 1.0;

    [self centerImageView];
}

/**
 *  Fetches this page's image from `YGRImageService` and displays it,
 *  showing a spinner while the fetch is in flight and an alert if it
 *  fails.
 */
- (void)loadPageImage
{
    NSUInteger generation = self.loadGeneration;
    
    [self.loadingSpinner startAnimating];
    
    __weak typeof(self) weakSelf = self;
    
    [[YGRImageService sharedService]
     fetchPageWithMangaId:self.mangaId
     chapterIndex:self.chapterIndex
     pageIndex:self.pageIndex
     priority:NSOperationQueuePriorityHigh
     completion:^(UIImage *pageData, NSError *error) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         if (!strongSelf) return;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             // Bail out before touching anything if this slot has been
             // reassigned since this fetch started.
             if (strongSelf.loadGeneration != generation) return;
             
             [strongSelf.loadingSpinner stopAnimating];
             
             if (error || !pageData)
             {
                 [strongSelf.delegate pageView:strongSelf didFailToLoadWithError:error];
                 return;
             }
             
             [strongSelf setImage:pageData];
         });
     }];
}

#pragma mark - Configuration / Reuse

- (void)configureWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSInteger)pageIndex
{
    self.mangaId = mangaId;
    self.chapterIndex = chapterIndex;
    self.pageIndex = pageIndex;
    
    // Invalidate any in-flight load for whatever page this slot previously
    // held, and clear stale content so it doesn't flash before the new
    // image arrives.
    [self prepareForReuse];
    
    [self loadPageImage];
}

- (void)prepareForReuse
{
    self.loadGeneration++;
    [self.loadingSpinner stopAnimating];
    self.imageView.image = nil;
    self.scrollView.zoomScale = 1.0;
}

@end
