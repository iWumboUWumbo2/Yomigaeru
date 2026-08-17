//
//  YGRAboutViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A grouped-style table screen showing basic build/version information
 *  about the app.
 */
@interface YGRAboutViewController : UITableViewController

#pragma mark - Initialization

/**
 *  Creates the about screen.
 *
 *  @return A newly initialized about view controller.
 */
- (instancetype)init;

@end
