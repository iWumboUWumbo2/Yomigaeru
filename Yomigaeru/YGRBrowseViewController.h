//
//  YGRBrowseContainerViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRChildRefreshDelegate.h"

@interface YGRBrowseViewController : UIViewController <YGRChildRefreshDelegate>

- (id)init;

@end
