//
//  YGRExtensionInfoViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGRExtension.h"

@interface YGRExtensionInfoViewController : UITableViewController

@property (nonatomic, strong) YGRExtension *extension;
@property (nonatomic, strong) UIImage *thumbnailImage;

@end
