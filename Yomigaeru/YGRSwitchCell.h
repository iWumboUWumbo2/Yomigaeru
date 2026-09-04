//
//  YGRSwitchCell.h
//  Yomigaeru
//
//  Created by John Connery on 9/4/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Identifies which setting a `YGRSwitchCell` controls, set as the cell's
 *  `tag` so `switchChanged:` knows which value in `YGRSettingsManager` to
 *  update.
 */
typedef NS_ENUM(NSInteger, YGRSwitchTag) {
    YGRSwitchTagPagingEnabled,
    YGRSwitchTagVerticalScrolling
};

/**
 *  A settings table cell pairing a `UISwitch` with a text label. Set `tag`
 *  to a `YGRSwitchTag` so the cell can persist changes to the matching
 *  `YGRSettingsManager` reader preference.
 */
@interface YGRSwitchCell : UITableViewCell

#pragma mark - Properties

/** The underlying switch control. */
@property (nonatomic, strong) UISwitch *toggle;

/** The current value, kept in sync with `toggle.on`. */
@property (nonatomic, assign) BOOL on;

@end
