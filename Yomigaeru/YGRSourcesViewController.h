//
//  YGRSourcesViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRRefreshable.h"
#import "YGRChildRefreshDelegate.h"

@interface YGRSourcesViewController : UITableViewController <YGRRefreshable>

@property (nonatomic, weak) id<YGRChildRefreshDelegate> refreshDelegate;

- (id)init;

@end
