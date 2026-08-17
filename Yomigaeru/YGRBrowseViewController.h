//
//  YGRBrowseContainerViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRChildRefreshDelegate.h"
#import <UIKit/UIKit.h>

/**
 *  Hosts the Sources and Extensions browse screens behind a segmented
 *  control, with a shared search bar and a refresh spinner that reflects
 *  whichever child is currently active.
 */
@interface YGRBrowseViewController : UIViewController <YGRChildRefreshDelegate, UISearchBarDelegate>

#pragma mark - Initialization

/**
 *  Creates the browse container view controller.
 *
 *  @return A newly initialized browse view controller.
 */
- (instancetype)init;

@end
