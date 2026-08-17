//
//  YGRTextFieldCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A settings table cell containing a single, centered text field, used for
 *  free-text input such as the server base URL.
 */
@interface YGRTextFieldCell : UITableViewCell

#pragma mark - Properties

/** The underlying text field, centered and inset within the cell's content view. */
@property (nonatomic, strong) UITextField *textField;

#pragma mark - Initialization

/**
 *  Creates a text field cell with a placeholder set on its text field.
 *
 *  @param style           The cell style, passed through to `UITableViewCell`.
 *  @param reuseIdentifier The reuse identifier, passed through to `UITableViewCell`.
 *  @param placeholder     The placeholder text shown in the text field when empty.
 *
 *  @return A newly initialized text field cell.
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                  placeholder:(NSString *)placeholder;

@end
