//
//  YGRLibraryCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"

@interface YGRLibraryCell : AQGridViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;

@end
