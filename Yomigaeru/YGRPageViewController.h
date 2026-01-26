//
//  YGRPageContentViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGRPageViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *mangaId;

@property (nonatomic, assign) NSInteger chapterIndex;
@property (nonatomic, assign) NSInteger pageIndex;

@end
