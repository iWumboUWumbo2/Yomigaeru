//
//  YGRPageContentViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRPageViewController.h"

#import "YGRImageService.h"
#import "YGRMangaService.h"

@interface YGRPageViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, assign) BOOL hasStartedLoading;

@end

@implementation YGRPageViewController

#pragma mark - Lifecycle

/**
 *  Builds the zoomable scroll view, image view, and loading spinner used to
 *  display the page. The image itself is not loaded until
 *  `viewWillAppear:`.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;

    [self.view addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    [self.scrollView addSubview:self.imageView];

    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect bounds = self.view.bounds;
    self.loadingSpinner.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    [self.view addSubview:self.loadingSpinner];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
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
    NSLog(@"[YGR-DEBUG] PageVC page=%ld setImage: image=%@ size=%@ scrollView.bounds=%@ thread=%@",
          (long) self.pageIndex, image, NSStringFromCGSize(image.size),
          NSStringFromCGRect(self.scrollView.bounds), [NSThread isMainThread] ? @"main" : @"bg");

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

    // Center vertically if image is shorter than screen
    if (height < scrollSize.height)
    {
        self.imageView.center = CGPointMake(scrollSize.width / 2, scrollSize.height / 2);
    }
}

/**
 *  Fetches this page's image from `YGRImageService` and displays it,
 *  showing a spinner while the fetch is in flight and an alert if it
 *  fails.
 */
- (void)loadPageImage
{
    NSLog(@"[YGR-DEBUG] PageVC page=%ld loadPageImage START mangaId=%@ chapterIndex=%lu self=%p "
          @"hasStartedLoading=%d",
          (long) self.pageIndex, self.mangaId, (unsigned long) self.chapterIndex, self,
          self.hasStartedLoading);

    // viewWillAppear: can end up firing twice for the same page — once via
    // UIPageViewController's automatic appearance forwarding (when it
    // happens to apply) and once via our own manual
    // beginAppearanceTransition:/endAppearanceTransition workaround in
    // YGRChapterViewController (see presentInitialPageViewController:). Make
    // this idempotent rather than trying to guarantee exactly one call site
    // wins.
    if (self.hasStartedLoading)
    {
        NSLog(@"[YGR-DEBUG] PageVC page=%ld loadPageImage — already started, skipping duplicate "
              @"call",
              (long) self.pageIndex);
        return;
    }
    self.hasStartedLoading = YES;

    [self.loadingSpinner startAnimating];

    __weak typeof(self) weakSelf = self;

    [[YGRImageService sharedService]
        fetchPageWithMangaId:self.mangaId
                chapterIndex:self.chapterIndex
                   pageIndex:self.pageIndex
                    priority:NSOperationQueuePriorityHigh
                  completion:^(UIImage *pageData, NSError *error) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;

                      NSLog(@"[YGR-DEBUG] PageVC page=%ld loadPageImage COMPLETION strongSelf=%p "
                            @"pageData=%@ error=%@ thread=%@",
                            (long) weakSelf.pageIndex, strongSelf, pageData, error,
                            [NSThread isMainThread] ? @"main" : @"bg");

                      if (!strongSelf)
                      {
                          NSLog(@"[YGR-DEBUG] PageVC page=%ld strongSelf is nil — deallocated "
                                @"before completion, bailing",
                                (long) weakSelf.pageIndex);
                      }

                      dispatch_async(dispatch_get_main_queue(), ^{
                          [strongSelf.loadingSpinner stopAnimating];
                      });

                      if (error || !pageData)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              UIAlertView *alert =
                                  [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to load page image"
                                                            delegate:strongSelf
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                              [alert show];
                          });
                          return;
                      }

                      dispatch_async(dispatch_get_main_queue(), ^{
                          NSLog(@"[YGR-DEBUG] PageVC page=%ld about to setImage: on main queue",
                                (long) strongSelf.pageIndex);
                          [strongSelf setImage:pageData];
                      });
                  }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"Dismissed");
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"[YGR-DEBUG] PageVC page=%ld viewWillAppear self=%p view.bounds=%@ view.window=%@",
          (long) self.pageIndex, self, NSStringFromCGRect(self.view.bounds), self.view.window);
    self.scrollView.zoomScale = 1.0;
    [self loadPageImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
