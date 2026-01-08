//
//  YGRTextFieldCell.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRTextFieldCell.h"

@implementation YGRTextFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                  placeholder:(NSString *)placeholder
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.placeholder = placeholder;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_textField];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat fieldHeight = 30.0;
    CGFloat fieldWidth = self.contentView.bounds.size.width * 0.9;
    CGFloat fieldX = (self.contentView.bounds.size.width - fieldWidth) / 2.0;
    CGFloat fieldY = (self.contentView.bounds.size.height - fieldHeight) / 2.0;
    self.textField.frame = CGRectMake(fieldX, fieldY, fieldWidth, fieldHeight);
}

@end
