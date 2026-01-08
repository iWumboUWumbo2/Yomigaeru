//
//  YGRTextFieldCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGRTextFieldCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier placeholder:(NSString *)placeholder;

@end
