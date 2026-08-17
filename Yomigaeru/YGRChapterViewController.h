//
//  YGRChapterViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//

#import <UIKit/UIKit.h>

#import "YGRChapter.h"
#import "YGRChildRefreshDelegate.h"
#import "YGRManga.h"

/**
 *  A page-view-controller-based chapter reader that pages through a
 *  chapter's images, tracks and persists reading progress, and prefetches
 *  nearby page images as the user reads.
 */
@interface YGRChapterViewController
    : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>

#pragma mark - Configuration

/** The manga whose chapters are being read. */
@property (nonatomic, strong) YGRManga *manga;
/** The display number of the currently loaded chapter (may be fractional, e.g. 10.5). */
@property (nonatomic, assign) double chapterNumber;
/** The 1-based index of the currently loaded chapter within the manga's chapter list. */
@property (nonatomic, assign) NSInteger chapterIndex;
/** The total number of chapters available for the manga. */
@property (nonatomic, assign) NSInteger chapterCount;
/** Notified after this controller finishes persisting reading progress for a chapter. */
@property (nonatomic, weak) id<YGRChildRefreshDelegate> refreshDelegate;

#pragma mark - Initialization

/**
 *  Creates a chapter reader configured with the given page view controller
 *  transition style.
 *
 *  @param style                 The page transition style to use.
 *  @param navigationOrientation The navigation orientation to use.
 *  @param options               Options dictionary forwarded to
 *  UIPageViewController.
 *
 *  @return A newly initialized chapter view controller.
 */
- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options;

#pragma mark - Chapter Loading

/**
 *  Fetches the chapter at the given index and, on success, displays its
 *  first unread page.
 *
 *  @param chapterIndex The 1-based index of the chapter to load.
 *  @param direction    The page transition direction to use when displaying
 *  the loaded chapter's first page.
 */
- (void)loadChapter:(NSInteger)chapterIndex
          direction:(UIPageViewControllerNavigationDirection)direction;

@end
