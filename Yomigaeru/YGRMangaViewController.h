//
//  YGRMangaViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2025/12/18.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRChildRefreshDelegate.h"
#import <UIKit/UIKit.h>

#import "YGRManga.h"

/**
 *  Displays the chapter list for a manga, supporting bulk read/bookmark
 *  status changes while editing, resuming the last-read chapter, and
 *  navigating to the manga's info screen.
 */
@interface YGRMangaViewController : UITableViewController <YGRChildRefreshDelegate>

/** The manga whose chapters are displayed. */
@property (nonatomic, strong) YGRManga *manga;

/**
 *  Creates a new manga view controller in plain table style.
 *
 *  @return An initialized YGRMangaViewController instance.
 */
- (instancetype)init;

@end
