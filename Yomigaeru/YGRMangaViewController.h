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
 *  When YES, hides the button that would otherwise push
 *  YGRMangaInfoViewController. Set by YGRMangaSplitViewController when this
 *  controller is embedded as its master pane on iPad, where the info
 *  screen is already visible alongside it and pushing it again would be
 *  redundant. Defaults to NO.
 */
@property (nonatomic, assign) BOOL hidesInfoButton;

/**
 *  When both are set, a Done button is added to the navigation bar
 *  invoking `doneAction` on `doneTarget`. Set by YGRMangaSplitViewController
 *  on its master pane, which is the one pinned to the screen's outer edge,
 *  to dismiss itself.
 */
@property (nonatomic, weak) id doneTarget;
@property (nonatomic, assign) SEL doneAction;

/**
 *  Creates a new manga view controller in plain table style.
 *
 *  @return An initialized YGRMangaViewController instance.
 */
- (instancetype)init;

@end
