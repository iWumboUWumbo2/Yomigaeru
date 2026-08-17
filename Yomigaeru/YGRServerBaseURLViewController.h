//
//  YGRServerBaseURLViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Lets the user view and edit the server's base URL via a single text
 *  field row, persisting the new value through YGRSettingsManager when
 *  editing ends.
 */
@interface YGRServerBaseURLViewController : UITableViewController

/**
 *  Creates a new server base URL settings screen.
 *
 *  @return An initialized YGRServerBaseURLViewController instance.
 */
- (instancetype)init;

@end
