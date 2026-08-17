//
//  YGRSourcesViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRChildRefreshDelegate.h"
#import "YGRRefreshable.h"
#import <UIKit/UIKit.h>

/**
 *  Lists available sources grouped by language, letting the user search and
 *  drill into a source's manga catalog.
 */
@interface YGRSourcesViewController : UITableViewController <YGRRefreshable, UISearchBarDelegate>

#pragma mark - Configuration

/** Notified via `childDidFinishRefreshing` once a source fetch completes. */
@property (nonatomic, weak) id<YGRChildRefreshDelegate> refreshDelegate;

#pragma mark - Initialization

/**
 *  Creates a sources view controller with a plain-style table view.
 *
 *  @return A newly initialized sources view controller.
 */
- (instancetype)init;

@end
