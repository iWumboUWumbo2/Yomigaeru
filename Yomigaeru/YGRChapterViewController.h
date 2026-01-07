//
//  YGRMangaPageViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGRChapter.h"
#import "YGRManga.h"

@interface YGRChapterViewController : UIPageViewController

- (id)init;

@property (nonatomic, strong) YGRManga *manga;
@property (nonatomic, strong) YGRChapter *chapter;

@end
