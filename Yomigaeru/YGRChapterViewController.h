//
//  YGRMangaPageViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGRChildRefreshDelegate.h"
#import "YGRChapter.h"
#import "YGRManga.h"

@interface YGRChapterViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) YGRManga *manga;

@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, assign) NSInteger chaptersArrayIndex;

@property (nonatomic, weak) id<YGRChildRefreshDelegate> refreshDelegate;

- (id)init;

@end
