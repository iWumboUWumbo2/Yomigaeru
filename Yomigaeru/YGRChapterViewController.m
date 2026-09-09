//
//  YGRChapterViewController.m
//  Yomigaeru
//
//  Created by John Connery on 8/20/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import "YGRChapterViewController.h"

#import "YGRImageService.h"
#import "YGRMangaService.h"
#import "YGRPageView.h"
#import "YGRSettingsManager.h"

@interface YGRChapterViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) YGRChapter *currentChapter;

@property (nonatomic, strong) UILabel *currentPageLabel;
@property (nonatomic, strong) UIProgressView *pageProgressView;
@property (nonatomic, strong) UILabel *totalPageLabel;

@property (nonatomic, strong) UIView *loadingOverlay;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *pageViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) BOOL isAnimatingPageTurn;

@end

@implementation YGRChapterViewController

#pragma mark - Init

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary *)options
{
    self = [super init];
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

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
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

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = [YGRSettingsManager sharedInstance].pagingEnabled;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.pageViews = @[ [[YGRPageView alloc] init],
                        [[YGRPageView alloc] init],
                        [[YGRPageView alloc] init] ];

    for (YGRPageView *slot in self.pageViews)
    {
        slot.delegate = self;
        [self.scrollView addSubview:slot];

        // Let a double tap (zoom) on any slot fully resolve before the
        // single-tap zones/nav-toggle gesture above decides it's just a
        // single tap.
        [tap requireGestureRecognizerToFail:slot.doubleTapGestureRecognizer];
    }

    [self repositionPageViewSlots];

    [self.view addSubview:self.scrollView];
}

/**
 *  Whether the reader is currently configured to page vertically, per
 *  `YGRSettingsManager`.
 */
- (BOOL)isVerticalReading
{
    return [YGRSettingsManager sharedInstance].readingDirection == YGRReadingDirectionVertical;
}

/**
 *  Lays out the three sliding slots along the reader's current scroll axis,
 *  sizing the scrollable content to include only the neighbors that
 *  actually exist. Slot 0 always holds the previous page's content, slot 1
 *  the current page, and slot 2 the next page's content — that spatial
 *  order never changes — but at the first or last page of a chapter one of
 *  those neighbors has nothing to show (see -configureSlot:withPage:
 *  pageCount:, which leaves it blank via -prepareForReuse). Previously the
 *  content was always exactly 3 slots wide regardless, so scrolling into
 *  that blank neighbor was always physically possible: nothing then
 *  brought the user back, since advanceForwards/advanceBackwards refuse to
 *  move past the real boundary, leaving them stranded looking at a blank
 *  page. Excluding a nonexistent neighbor from contentSize entirely makes
 *  scrolling to it impossible in the first place — attempting to do so
 *  just rubber-bands, like any other paging reader's end-of-content
 *  bounce.
 */
- (void)repositionPageViewSlots
{
    BOOL vertical = self.isVerticalReading;
    CGFloat pageWidth = self.view.bounds.size.width;
    CGFloat pageHeight = self.view.bounds.size.height;
    CGFloat pageExtent = vertical ? pageHeight : pageWidth;

    BOOL hasPrevious = self.currentChapter && self.currentPage > 0;
    BOOL hasNext = self.currentChapter && self.currentPage < self.currentChapter.pageCount - 1;

    CGFloat currentPosition = hasPrevious ? 1.0f : 0.0f;
    NSUInteger reachableSlotCount = 1 + (hasPrevious ? 1 : 0) + (hasNext ? 1 : 0);

    for (NSUInteger i = 0; i < self.pageViews.count; i++)
    {
        YGRPageView *slot = self.pageViews[i];
        CGFloat position = currentPosition + ((CGFloat) i - 1.0f);
        slot.frame = vertical
            ? CGRectMake(0.0f, position * pageExtent, pageWidth, pageHeight)
            : CGRectMake(position * pageExtent, 0.0f, pageWidth, pageHeight);
    }

    self.scrollView.contentSize = vertical
        ? CGSizeMake(pageWidth, pageExtent * reachableSlotCount)
        : CGSizeMake(pageExtent * reachableSlotCount, pageHeight);

    self.scrollView.contentOffset = vertical
        ? CGPointMake(0.0f, currentPosition * pageExtent)
        : CGPointMake(currentPosition * pageExtent, 0.0f);
}

/**
 *  Loads the chapter from scratch if none is loaded yet.
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
        [self loadChapter:self.chapterIndex];
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

    if (!self.currentChapter)
        return;

    __weak typeof(self) weakSelf = self;

    NSDictionary *parameters;
    if (self.currentPage == self.currentChapter.pageCount - 1)
    {
        parameters = @{@"read" : @"true", @"lastPageRead" : @(self.currentPage)};
    }
    else
    {
        parameters = @{@"lastPageRead" : @(self.currentPage)};
    }

    [self.mangaService modifyChapterWithMangaId:self.manga.id_
                                   chapterIndex:self.chapterIndex
                                     parameters:parameters
                                     completion:^(BOOL success, NSError *error) {
                                         __strong typeof(weakSelf) strongSelf = weakSelf;
                                         if (!strongSelf)
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
                                         if ([strongSelf.refreshDelegate respondsToSelector:@selector
                                              (childDidFinishRefreshing)])
                                         {
                                             [strongSelf.refreshDelegate childDidFinishRefreshing];
                                         }
                                     }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - YGRPageViewDelegate

- (void)pageView:(YGRPageView *)pageView didFailToLoadWithError:(NSError *)error
{
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"Failed to load page image"
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alert show];
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

/**
 *  With horizontal paging, a tap in the left or right third of the screen
 *  turns the page instead of toggling the nav bar; a tap in the middle
 *  third (or any tap when paging/vertical scrolling is active) falls back
 *  to the usual toggle.
 */
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if ([YGRSettingsManager sharedInstance].pagingEnabled && !self.isVerticalReading)
    {
        CGFloat width = self.view.bounds.size.width;
        CGFloat x = [recognizer locationInView:self.view].x;

        if (x < width / 3.0f)
        {
            [self advanceBackwards:YES];
            return;
        }
        else if (x > width * 2.0f / 3.0f)
        {
            [self advanceForwards:YES];
            return;
        }
    }

    [self toggleNavigationBar];
}

#pragma mark - Loading Overlay

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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.currentChapter)
        return;

    BOOL vertical = self.isVerticalReading;
    CGFloat pageExtent = vertical ? self.view.bounds.size.height : self.view.bounds.size.width;
    CGFloat offset = vertical ? self.scrollView.contentOffset.y : self.scrollView.contentOffset.x;

    // Slot positions shift depending on which neighbors exist (see
    // -repositionPageViewSlots), so the "current" slot isn't always at a
    // fixed offset -- recompute where it is now and compare against that,
    // rather than assuming it's always the middle of a fixed 3-wide strip.
    BOOL hasPrevious = self.currentPage > 0;
    CGFloat currentPosition = hasPrevious ? 1.0f : 0.0f;
    NSInteger scrolledPosition = (NSInteger) roundf(offset / pageExtent);

    if (scrolledPosition > currentPosition && self.currentPage < self.currentChapter.pageCount - 1)
    {
        [self advanceForwards:NO];
    }
    else if (scrolledPosition < currentPosition && self.currentPage > 0)
    {
        [self advanceBackwards:NO];
    }
}

/**
 *  Advances to the next page. Swiping already visually moves the scroll
 *  view before this is ever called (it runs from -scrollViewDidEndDecelerating:,
 *  after the user's own drag has settled), so the recycle-and-recenter
 *  below needs no animation of its own there. A tap zone has no drag to
 *  ride along with, so `animated:YES` drives that motion explicitly first
 *  and only recycles once it's done -- see -handleSingleTap:.
 */
- (void)advanceForwards:(BOOL)animated
{
    if (self.isAnimatingPageTurn || !self.currentChapter
        || self.currentPage >= self.currentChapter.pageCount - 1)
    {
        return;
    }

    if (!animated)
    {
        [self performAdvanceForwards];
        return;
    }

    self.isAnimatingPageTurn = YES;

    BOOL vertical = self.isVerticalReading;
    CGFloat pageExtent = vertical ? self.view.bounds.size.height : self.view.bounds.size.width;
    CGFloat nextPosition = (self.currentPage > 0 ? 1.0f : 0.0f) + 1.0f;

    CGPoint targetOffset = vertical
        ? CGPointMake(0.0f, nextPosition * pageExtent)
        : CGPointMake(nextPosition * pageExtent, 0.0f);

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25
        animations:^{
            weakSelf.scrollView.contentOffset = targetOffset;
        }
        completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf performAdvanceForwards];
            strongSelf.isAnimatingPageTurn = NO;
        }];
}

- (void)performAdvanceForwards
{
    self.currentPage++;

    YGRPageView *recycled = self.pageViews[0];
    self.pageViews = @[ self.pageViews[1], self.pageViews[2], recycled ];

    [self repositionPageViewSlots];

    [self configureSlot:recycled
                   withPage:self.currentPage + 1
                  pageCount:self.currentChapter.pageCount];

    [self updateToolbarWithCurrentPage:self.currentPage];
    [self prefetchAroundPage:self.currentPage];
}

- (void)configureSlot:(YGRPageView *)slot
                 withPage:(NSInteger)pageIndex
                pageCount:(NSInteger)pageCount
{
    if (pageIndex < 0 || pageIndex >= pageCount)
    {
        [slot prepareForReuse];
        return;
    }

    [slot configureWithMangaId:self.currentChapter.mangaId
                  chapterIndex:self.chapterIndex
                     pageIndex:pageIndex];
}

/**
 *  Backward counterpart to -advanceForwards:; see its comment.
 */
- (void)advanceBackwards:(BOOL)animated
{
    if (self.isAnimatingPageTurn || self.currentPage <= 0)
    {
        return;
    }

    if (!animated)
    {
        [self performAdvanceBackwards];
        return;
    }

    self.isAnimatingPageTurn = YES;

    BOOL vertical = self.isVerticalReading;
    CGFloat pageExtent = vertical ? self.view.bounds.size.height : self.view.bounds.size.width;
    CGFloat previousPosition = (self.currentPage > 0 ? 1.0f : 0.0f) - 1.0f;

    CGPoint targetOffset = vertical
        ? CGPointMake(0.0f, previousPosition * pageExtent)
        : CGPointMake(previousPosition * pageExtent, 0.0f);

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25
        animations:^{
            weakSelf.scrollView.contentOffset = targetOffset;
        }
        completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf performAdvanceBackwards];
            strongSelf.isAnimatingPageTurn = NO;
        }];
}

- (void)performAdvanceBackwards
{
    self.currentPage--;

    YGRPageView *recycled = self.pageViews[2];
    self.pageViews = @[ recycled, self.pageViews[0], self.pageViews[1] ];

    [self repositionPageViewSlots];

    [self configureSlot:recycled
                   withPage:(NSInteger) self.currentPage - 1
                  pageCount:self.currentChapter.pageCount];

    [self updateToolbarWithCurrentPage:self.currentPage];
    [self prefetchAroundPage:self.currentPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Chapter Loading

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

- (void)loadChapter:(NSInteger)chapterIndex
{
    if (chapterIndex < 1 || chapterIndex > self.chapterCount)
    {
        return;
    }

    [self showLoadingOverlay];

    __weak typeof(self) weakSelf = self;
    [self.mangaService fetchChapterWithMangaId:self.manga.id_ chapterIndex:chapterIndex completion:^(YGRChapter *chapter, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf hideLoadingOverlay];
        });

        if (error || !chapter || chapter.pageCount == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;

                UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Failed to load chapter"
                                          delegate:strongSelf
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
                [alert show];
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            strongSelf.currentChapter = chapter;
            strongSelf.chapterIndex = chapterIndex;
            strongSelf.chapterNumber = chapter.chapterNumber;

            strongSelf.currentPage = MAX(0, MIN(chapter.lastPageRead, chapter.pageCount - 1));

            [strongSelf repositionPageViewSlots];

            if (strongSelf.currentPage > 0)
            {
                [strongSelf.pageViews[0] configureWithMangaId:strongSelf.manga.id_ chapterIndex:strongSelf.chapterIndex pageIndex:strongSelf.currentPage - 1];
            }

            [strongSelf.pageViews[1] configureWithMangaId:strongSelf.manga.id_ chapterIndex:strongSelf.chapterIndex pageIndex:strongSelf.currentPage];

            if (strongSelf.currentPage < chapter.pageCount - 1)
            {
                [strongSelf.pageViews[2] configureWithMangaId:strongSelf.manga.id_ chapterIndex:strongSelf.chapterIndex pageIndex:strongSelf.currentPage + 1];
            }

            [strongSelf updateToolbarWithCurrentPage:strongSelf.currentPage];
            [strongSelf prefetchAroundPage:strongSelf.currentPage];
        });
    }];
}

@end
