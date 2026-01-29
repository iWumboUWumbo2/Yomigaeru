//
//  YGRLibraryCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "AQGridViewCell.h"
#import <UIKit/UIKit.h>

@interface YGRLibraryCell : AQGridViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger unreadCount;

- (void)hideBorder;
- (void)showBorder;

- (void)showLoadingSpinner;
- (void)hideLoadingSpinner;

@end
