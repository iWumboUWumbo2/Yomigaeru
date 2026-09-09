//
//  YGRExtensionsViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRRefreshable.h"
#import <UIKit/UIKit.h>

/**
 *  Lists installed, available, and update-pending extensions in a
 *  plain-style, swipeable table, letting the user install, remove, or
 *  update each one and drill into its details. Supports
 *  swipe-down-to-refresh.
 */
@interface YGRExtensionsViewController : UITableViewController <YGRRefreshable, UISearchBarDelegate>

#pragma mark - Initialization

/**
 *  Creates an extensions view controller with a plain-style table view.
 *
 *  @return A newly initialized extensions view controller.
 */
- (instancetype)init;

@end
