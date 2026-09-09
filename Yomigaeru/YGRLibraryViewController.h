//
//  YGRLibraryViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Displays the user's manga library as a grid, supporting refreshing,
 *  navigating into a manga, and long-press bulk actions (delete, mark
 *  read, mark unread).
 *
 *  Renders with UICollectionView on iOS 6+ and falls back to AQGridView on
 *  iOS 5, chosen automatically at runtime.
 */
@interface YGRLibraryViewController : UIViewController

/**
 *  Creates a new library grid view controller, sizing its grid cells based
 *  on the current screen width and device idiom.
 *
 *  @return An initialized YGRLibraryViewController instance.
 */
- (instancetype)init;

@end
