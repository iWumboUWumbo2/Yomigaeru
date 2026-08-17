//
//  YGRSettingsViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Top-level settings screen, listing the app's setting categories
 *  ("Server", "Reader", "About") and pushing their respective screens.
 */
@interface YGRSettingsViewController : UITableViewController

/**
 *  Creates a new top-level settings screen.
 *
 *  @return An initialized YGRSettingsViewController instance.
 */
- (instancetype)init;

@end
