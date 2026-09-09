//
//  YGRBrowseContainerViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Hosts the Sources and Extensions browse screens behind a segmented
 *  control, with a shared search bar. Each child manages its own
 *  swipe-down-to-refresh independently.
 */
@interface YGRBrowseViewController : UIViewController <UISearchBarDelegate>

#pragma mark - Initialization

/**
 *  Creates the browse container view controller.
 *
 *  @return A newly initialized browse view controller.
 */
- (instancetype)init;

@end
