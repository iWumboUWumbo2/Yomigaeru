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

@interface YGRChapterViewController
    : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) YGRManga *manga;
@property (nonatomic, assign) double chapterNumber;
@property (nonatomic, assign) NSInteger chapterIndex;
@property (nonatomic, assign) NSInteger chapterCount;
@property (nonatomic, weak) id<YGRChildRefreshDelegate> refreshDelegate;

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options;
- (void)loadChapter:(NSInteger)chapterIndex
          direction:(UIPageViewControllerNavigationDirection)direction;

@end
