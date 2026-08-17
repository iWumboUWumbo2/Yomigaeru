//
//  YGRReaderSettingsViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/30.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Table view screen for reader-related settings, currently exposing
 *  stepper controls for the number of pages to prefetch ahead of and
 *  behind the current page.
 */
@interface YGRReaderSettingsViewController : UITableViewController

/**
 *  Creates a new reader settings screen listing the reader-related
 *  preference rows.
 *
 *  @return An initialized YGRReaderSettingsViewController instance.
 */
- (instancetype)init;

@end
