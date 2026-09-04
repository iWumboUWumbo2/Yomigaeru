//
//  YGRChapterViewController.h
//  Yomigaeru
//
//  Created by John Connery on 8/20/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGRChapter.h"
#import "YGRChildRefreshDelegate.h"
#import "YGRManga.h"
#import "YGRPageView.h"

@interface YGRChapterViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, YGRPageViewDelegate>

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
 *  Creates a chapter reader. The transition style/navigation orientation
 *  parameters are accepted for call-site compatibility but are otherwise
 *  unused, since this reader pages via its own sliding `UIScrollView`
 *  rather than `UIPageViewController`.
 *
 *  @param style                 Unused.
 *  @param navigationOrientation Unused.
 *  @param options               Unused.
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
 */
- (void)loadChapter:(NSInteger)chapterIndex;

@end
