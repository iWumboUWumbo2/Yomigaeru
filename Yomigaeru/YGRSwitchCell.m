//
//  YGRSwitchCell.m
//  Yomigaeru
//
//  Created by John Connery on 9/4/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import "YGRSwitchCell.h"
#import "YGRSettingsManager.h"

@implementation YGRSwitchCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _toggle = [[UISwitch alloc] init];

        [_toggle addTarget:self
                    action:@selector(switchChanged:)
          forControlEvents:UIControlEventValueChanged];

        self.accessoryView = _toggle;
    }
    return self;
}

#pragma mark - Value handling

- (void)setOn:(BOOL)on
{
    _on = on;
    self.toggle.on = on;
}

/**
 *  Target-action handler for the switch's value-changed event. Updates
 *  `on`, then persists the new value to the `YGRSettingsManager` reader
 *  preference matching this cell's `tag`.
 *
 *  @param sender The switch whose value changed.
 */
- (void)switchChanged:(UISwitch *)sender
{
    self.on = sender.on;

    switch (self.tag) {
        case YGRSwitchTagPagingEnabled:
            [[YGRSettingsManager sharedInstance] setPagingEnabled:self.on];
            break;

        case YGRSwitchTagVerticalScrolling:
            [[YGRSettingsManager sharedInstance] setReadingDirection:
                self.on ? YGRReadingDirectionVertical : YGRReadingDirectionHorizontal];
            break;

        default:
            break;
    }
}

@end
