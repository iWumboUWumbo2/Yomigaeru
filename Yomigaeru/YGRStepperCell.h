//
//  YGRStepperCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/30.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YGRStepperTag) {
    YGRStepperTagNextPrefetch,
    YGRStepperTagPreviousPrefetch
};

@interface YGRStepperCell : UITableViewCell

@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, assign) NSInteger value;

@property (nonatomic, assign) NSInteger minimumValue;
@property (nonatomic, assign) NSInteger maximumValue;

@end
