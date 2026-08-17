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

@interface YGRSourcesViewController : UITableViewController <YGRRefreshable, UISearchBarDelegate>

@property (nonatomic, weak) id<YGRChildRefreshDelegate> refreshDelegate;

- (instancetype)init;

@end
