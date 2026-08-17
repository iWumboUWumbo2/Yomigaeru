//
//  YGRStepperCell.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/30.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRStepperCell.h"
#import "YGRSettingsManager.h"

@implementation YGRStepperCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _stepper = [[UIStepper alloc] init];
        _stepper.stepValue = 1;
        
        [_stepper addTarget:self
                     action:@selector(stepperChanged:)
           forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:_stepper];
        
        _minimumValue = 0;
        _maximumValue = 100;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.stepper.frame.size;
    
    CGFloat x = self.contentView.bounds.size.width - size.width - 10;
    CGFloat y = (self.contentView.bounds.size.height - size.height) / 2;
    
    self.stepper.frame = CGRectMake(x, y, size.width, size.height);
}

#pragma mark - Value handling

- (void)setValue:(NSInteger)value
{
    _value = value;
    self.stepper.value = value;
    self.textLabel.text =
    [NSString stringWithFormat:@"%ld", (long)value];
}

- (void)setMinimumValue:(NSInteger)minimumValue
{
    _minimumValue = minimumValue;
    self.stepper.minimumValue = minimumValue;
}

- (void)setMaximumValue:(NSInteger)maximumValue
{
    _maximumValue = maximumValue;
    self.stepper.maximumValue = maximumValue;
}

/**
 *  Target-action handler for the stepper's value-changed event. Updates
 *  `value`/the text label, then persists the new value to the
 *  `YGRSettingsManager` prefetch count matching this cell's `tag`.
 *
 *  @param sender The stepper whose value changed.
 */
- (void)stepperChanged:(UIStepper *)sender
{
    self.value = (NSInteger)sender.value;
    self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)self.value];
    
    switch (self.tag) {
        case YGRStepperTagNextPrefetch:
            [[YGRSettingsManager sharedInstance] setNextPrefetchCount:self.value];
            break;
            
        case YGRStepperTagPreviousPrefetch:
            [[YGRSettingsManager sharedInstance] setPreviousPrefetchCount:self.value];
            break;
            
        default:
            break;
    }
}

@end