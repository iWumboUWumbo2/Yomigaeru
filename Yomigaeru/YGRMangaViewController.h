//
//  YGRMangaViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2025/12/18.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRChildRefreshDelegate.h"
#import <UIKit/UIKit.h>

#import "YGRManga.h"

@interface YGRMangaViewController : UITableViewController <YGRChildRefreshDelegate>

@property (nonatomic, strong) YGRManga *manga;

- (instancetype)init;

@end
