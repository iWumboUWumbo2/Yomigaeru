//
//  YGRChapterViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//

#import "YGRChapterViewController.h"
#import "YGRImageService.h"
#import "YGRMangaService.h"
#import "YGRPageViewController.h"
#import "YGRSettingsManager.h"

@interface YGRChapterViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) YGRChapter *currentChapter;

@property (nonatomic, strong) UILabel *currentPageLabel;
@property (nonatomic, strong) UIProgressView *pageProgressView;
@property (nonatomic, strong) UILabel *totalPageLabel;

@property (nonatomic, strong) UIView *loadingOverlay;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@end

@implementation YGRChapterViewController

#pragma mark - Init

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style
                    navigationOrientation:navigationOrientation
                                  options:options];
    if (self)
    {
        _mangaService = [[YGRMangaService alloc] init];
    }
    return self;
}

#pragma mark - Lifecycle

/**
 *  Builds the toolbar items: current-page label, a stretching progress bar,
 *  and total-page label.
 */
- (void)configureToolbar
{
    self.currentPageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.currentPageLabel.text = @"–";
    self.currentPageLabel.backgroundColor = [UIColor clearColor];

    self.totalPageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.totalPageLabel.text = @"–";
    self.totalPageLabel.backgroundColor = [UIColor clearColor];

    self.currentPageLabel.font = self.totalPageLabel.font = [UIFont boldSystemFontOfSize:13.0f];

    [self.currentPageLabel sizeToFit];
    [self.totalPageLabel sizeToFit];

    // Container that will stretch
    CGFloat toolbarHeight = 44.0f;
    CGFloat minWidth = 100.0f;

    UIView *progressContainer =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, minWidth, toolbarHeight)];
    progressContainer.backgroundColor = [UIColor clearColor];

    self.pageProgressView =
        [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    CGFloat progressHeight = self.pageProgressView.bounds.size.height;
    if (progressHeight <= 0.0f)
    {
        progressHeight = 9.0f; // iOS 5 default height
    }

    CGFloat y = floorf((toolbarHeight - progressHeight) / 2.0f) - 1.0f;

    self.pageProgressView.frame =
        CGRectMake(0, y, progressContainer.bounds.size.width, progressHeight);
    self.pageProgressView.progress = 0.0f;

    [progressContainer addSubview:self.pageProgressView];

    UIBarButtonItem *currentItem =
        [[UIBarButtonItem alloc] initWithCustomView:self.currentPageLabel];

    UIBarButtonItem *progressItem = [[UIBarButtonItem alloc] initWithCustomView:progressContainer];

    UIBarButtonItem *totalItem = [[UIBarButtonItem alloc] initWithCustomView:self.totalPageLabel];

    UIBarButtonItem *flex =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];

    self.toolbarItems = @[ currentItem, flex, progressItem, flex, totalItem ];
}

/**
 *  Resizes the progress bar's container to fill the space between the
 *  current/total page labels within the toolbar's current width.
 */
- (void)layoutToolbar
{
    UIToolbar *toolbar = self.navigationController.toolbar;
    if (!toolbar)
        return;

    CGFloat totalWidth = toolbar.bounds.size.width;

    UIView *container = self.pageProgressView.superview;
    CGFloat leftWidth = self.currentPageLabel.bounds.size.width;
    CGFloat rightWidth = self.totalPageLabel.bounds.size.width;
    CGFloat padding = 30.0f; // space + margins

    CGFloat containerWidth = totalWidth - leftWidth - rightWidth - padding;

    if (containerWidth < 50.0f)
        containerWidth = 50.0f;

    CGRect frame = container.frame;
    frame.size.width = containerWidth;
    container.frame = frame;

    CGRect containerBounds = container.bounds;

    CGFloat progressHeight = self.pageProgressView.bounds.size.height;
    if (progressHeight <= 0.0f)
    {
        progressHeight = 9.0f;
    }

    CGFloat y = floorf((containerBounds.size.height - progressHeight) / 2.0f) - -2.0f;

    CGRect progressFrame = self.pageProgressView.frame;
    progressFrame.origin.y = y;
    progressFrame.size.width = containerBounds.size.width;
    self.pageProgressView.frame = progressFrame;
}

/**
 *  Updates the toolbar's page labels and progress bar for the given page,
 *  then re-lays out the toolbar to match the labels' new sizes.
 *
 *  @param page The 0-based index of the page now being displayed.
 */
- (void)updateToolbarWithCurrentPage:(NSInteger)page
{
    NSInteger pageCount = MAX(self.currentChapter.pageCount, 1);

    // Update current page
    self.currentPageLabel.text = [NSString stringWithFormat:@"%ld", (long) (page + 1)];
    [self.currentPageLabel sizeToFit];

    // Update total pages
    self.totalPageLabel.text = [NSString stringWithFormat:@"%ld", (long) pageCount];
    [self.totalPageLabel sizeToFit];

    // Update progress
    float progress = (float) (page + 1) / (float) pageCount;
    [self.pageProgressView setProgress:MIN(progress, 1.0f) animated:YES];

    // Resize the progress container if needed
    [self layoutToolbar];
}

/**
 *  Sets the chapter title, installs the back button and tap-to-toggle-bars
 *  gesture, builds the toolbar, and prepares (but does not show) the
 *  loading overlay.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title =
        [NSString stringWithFormat:@"Chapter %@",
                                   (floor(self.chapterNumber) == self.chapterNumber)
                                       ? [NSString stringWithFormat:@"%.0f", self.chapterNumber]
                                       : [NSString stringWithFormat:@"%.1f", self.chapterNumber]];

    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(dismissSelf)];

    self.dataSource = self;
    self.delegate = self;

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];

    [self configureToolbar];
    [self.navigationController setToolbarHidden:NO animated:NO];

    self.loadingOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    self.loadingOverlay.backgroundColor = [UIColor blackColor];
    self.loadingOverlay.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect bounds = self.view.bounds;
    self.loadingSpinner.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    [self.loadingOverlay addSubview:self.loadingSpinner];
}

/**
 *  Loads the chapter from scratch if none is loaded yet; otherwise restores
 *  the page the user last read.
 *
 *  @param animated Whether the appearance is animated.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];

    if (!self.currentChapter)
    {
        [self loadChapter:self.chapterIndex
                direction:UIPageViewControllerNavigationDirectionForward];
    }
    else
    {
        NSInteger pageIndex =
            MAX(0, MIN(self.currentChapter.lastPageRead, self.currentChapter.pageCount - 1));

        UIViewController *pageVC = [self viewControllerForPage:pageIndex];
        if (pageVC)
        {
            [self setViewControllers:@[ pageVC ]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:nil];

            [self updateToolbarWithCurrentPage:pageIndex];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutToolbar];
}

/**
 *  Persists the current page (and read status, if the last page was
 *  reached) back to the server, then notifies `refreshDelegate`.
 *
 *  @param animated Whether the disappearance is animated.
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    YGRPageViewController *currentPageVC =
        (YGRPageViewController *) self.viewControllers.firstObject;
    if (!currentPageVC)
        return;

    __weak typeof(self) weakSelf = self;
    
    NSDictionary *parameters;
    if (currentPageVC.pageIndex == self.currentChapter.pageCount - 1)
    {
        parameters = @{@"read" : @"true", @"lastPageRead" : @(currentPageVC.pageIndex)};
    }
    else
    {
        parameters = @{@"lastPageRead" : @(currentPageVC.pageIndex)};
    }
    
    [self.mangaService modifyChapterWithMangaId:self.manga.id_
                                   chapterIndex:self.chapterIndex
                                     parameters:parameters
                                     completion:^(BOOL success, NSError *error) {
                                         __strong typeof(weakSelf) self = weakSelf;
                                         if (!self)
                                             return;
                                         if (error || !success)
                                         {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 UIAlertView *alert = [[UIAlertView alloc]
                                                                       initWithTitle:@"Error"
                                                                       message:
                                                                       @"Failed to save reading progress"
                                                                       delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                                                 [alert show];
                                             });
                                         }
                                         if ([self.refreshDelegate respondsToSelector:@selector
                                              (childDidFinishRefreshing)])
                                         {
                                             [self.refreshDelegate childDidFinishRefreshing];
                                         }
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

#pragma mark - Navigation

/**
 *  Dismisses the chapter reader.
 */
- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Toggles the visibility of the navigation bar and toolbar together.
 */
- (void)toggleNavigationBar
{
    BOOL hidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!hidden animated:YES];
    [self.navigationController setToolbarHidden:!hidden animated:YES];
}

#pragma mark - Chapter/Page Helpers

/**
 *  Builds a page view controller configured to display the given page of
 *  the current chapter.
 *
 *  @param pageIndex The 0-based page index to display.
 *
 *  @return A configured `YGRPageViewController`, or `nil` if the index is
 *  out of range or no chapter is currently loaded.
 */
- (UIViewController *)viewControllerForPage:(NSInteger)pageIndex
{
    if (!self.currentChapter || pageIndex < 0 || pageIndex >= self.currentChapter.pageCount)
    {
        return nil;
    }

    YGRPageViewController *pageVC = [[YGRPageViewController alloc] init];
    pageVC.mangaId = self.manga.id_;
    pageVC.chapterIndex = self.chapterIndex;
    pageVC.pageIndex = pageIndex;

    return pageVC;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{

    YGRPageViewController *currentPageVC = (YGRPageViewController *) viewController;
    NSInteger previousPage = currentPageVC.pageIndex - 1;
    if (previousPage < 0)
        return nil; // Don't load previous chapter
    return [self viewControllerForPage:previousPage];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{

    YGRPageViewController *currentPageVC = (YGRPageViewController *) viewController;
    NSInteger nextPage = currentPageVC.pageIndex + 1;
    if (nextPage >= self.currentChapter.pageCount)
        return nil; // Don't load next chapter
    return [self viewControllerForPage:nextPage];
}

#pragma mark - Chapter Loading

/**
 *  Eagerly fetches every page image for the given chapter at low priority.
 *  Currently unused (the call site is commented out).
 *
 *  @param chapter The chapter whose pages should be prefetched.
 */
- (void)prefetchImagesForChapter:(YGRChapter *)chapter
{
    if (!chapter)
        return;

    for (NSInteger pageIndex = 0; pageIndex < chapter.pageCount; pageIndex++)
    {
        [[YGRImageService sharedService]
            fetchPageWithMangaId:self.manga.id_
                    chapterIndex:self.chapterIndex
                       pageIndex:pageIndex
                        priority:NSOperationQueuePriorityLow
                      completion:^(UIImage *image, NSError *error) {
                          if (error)
                          {
                              NSLog(@"Prefetch failed for page %ld: %@", (long) pageIndex, error);
                          }
                      }];
    }
}

/**
 *  Prefetches page images within a window around the given page, sized by
 *  the user's previous/next prefetch-count settings.
 *
 *  @param pageIndex The 0-based page index to prefetch around.
 */
- (void)prefetchAroundPage:(NSInteger)pageIndex
{
    if (!self.currentChapter) return;
    
    NSInteger pageCount = self.currentChapter.pageCount;
    
    YGRSettingsManager *settingsManager = [YGRSettingsManager sharedInstance];
    
    NSInteger start = MAX(0, pageIndex - settingsManager.previousPrefetchCount);
    NSInteger end   = MIN(pageCount - 1, pageIndex + settingsManager.nextPrefetchCount);
    
    for (NSInteger i = start; i <= end; i++)
    {
        [[YGRImageService sharedService]
         fetchPageWithMangaId:self.manga.id_
         chapterIndex:self.chapterIndex
         pageIndex:i
         priority:NSOperationQueuePriorityLow
         completion:nil];
    }
}

/**
 *  Adds the loading overlay to the view (if needed) and starts its spinner.
 */
- (void)showLoadingOverlay
{
    if (![self.loadingOverlay superview])
    {
        [self.view addSubview:self.loadingOverlay];
    }
    [self.loadingSpinner startAnimating];
}

/**
 *  Stops the loading spinner and removes the loading overlay from the view.
 */
- (void)hideLoadingOverlay
{
    [self.loadingSpinner stopAnimating];
    [self.loadingOverlay removeFromSuperview];
}

- (void)loadChapter:(NSInteger)chapterIndex
          direction:(UIPageViewControllerNavigationDirection)direction
{
    if (chapterIndex < 1 || chapterIndex > self.chapterCount)
        return;

    [self showLoadingOverlay];

    __weak typeof(self) weakSelf = self;
    [self.mangaService
        fetchChapterWithMangaId:self.manga.id_
                   chapterIndex:chapterIndex
                     completion:^(YGRChapter *chapter, NSError *error) {
                         __strong typeof(weakSelf) self = weakSelf;
                         if (!self)
                             return;

                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self hideLoadingOverlay];
                         });

                         if (error || !chapter || chapter.pageCount == 0)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 UIAlertView *alert =
                                     [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Failed to load chapter"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                                 [alert show];
                             });
                             return;
                         }

                         self.currentChapter = chapter;
                         self.chapterIndex = chapterIndex;
                         self.chapterNumber = chapter.chapterNumber;

                         NSInteger startPage =
                             MAX(0, MIN(chapter.lastPageRead, chapter.pageCount - 1));
                         UIViewController *pageVC = [self viewControllerForPage:startPage];
                         if (!pageVC)
                             return;

                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self setViewControllers:@[ pageVC ]
                                            direction:direction
                                             animated:NO
                                           completion:nil];

                             [self updateToolbarWithCurrentPage:startPage];
//                             [self prefetchImagesForChapter:chapter];
                         });
                     }];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers
        transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        YGRPageViewController *currentViewController =
            (YGRPageViewController *) pageViewController.viewControllers.firstObject;
        [self updateToolbarWithCurrentPage:currentViewController.pageIndex];
        [self prefetchAroundPage:currentViewController.pageIndex];
    }
}

@end
