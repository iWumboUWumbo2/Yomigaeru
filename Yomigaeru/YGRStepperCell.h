//
//  YGRStepperCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/30.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Identifies which setting a `YGRStepperCell` controls, set as the cell's
 *  `tag` so `stepperChanged:` knows which value in `YGRSettingsManager` to
 *  update.
 */
typedef NS_ENUM(NSInteger, YGRStepperTag) {
    YGRStepperTagNextPrefetch,
    YGRStepperTagPreviousPrefetch
};

/**
 *  A settings table cell pairing a `UIStepper` with a text label that shows
 *  the stepper's current value. Set `tag` to a `YGRStepperTag` so the cell
 *  can persist changes to the matching `YGRSettingsManager` prefetch count.
 */
@interface YGRStepperCell : UITableViewCell

#pragma mark - Properties

/** The underlying stepper control. */
@property (nonatomic, strong) UIStepper *stepper;

/** The current value, kept in sync with `stepper.value` and the text label. */
@property (nonatomic, assign) NSInteger value;

/** The stepper's minimum allowed value. Defaults to 0. */
@property (nonatomic, assign) NSInteger minimumValue;

/** The stepper's maximum allowed value. Defaults to 100. */
@property (nonatomic, assign) NSInteger maximumValue;

@end
