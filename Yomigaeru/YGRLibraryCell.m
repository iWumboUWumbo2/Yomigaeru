//
//  YGRLibraryCell.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRLibraryCell.h"
#import <QuartzCore/QuartzCore.h>

@interface YGRLibraryCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation YGRLibraryCell

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (!self)
        return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    
    // Image view
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.cornerRadius = 5.0f;      // adjust radius as desired
    _imageView.layer.masksToBounds = YES;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:_imageView];
    
    // Title label
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textColor = [UIColor darkTextColor];
    _titleLabel.highlightedTextColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.minimumFontSize = 10.0f;
    _titleLabel.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:_titleLabel];
    
    return self;
}

#pragma mark - Properties

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentBounds = self.contentView.bounds;
    
    CGFloat padding = 10.0f;
    CGFloat titleHeight = 30.0f;
    
    // Title (bottom)
    CGRect titleFrame = CGRectMake(
                                   padding,
                                   CGRectGetHeight(contentBounds) - titleHeight - padding,
                                   CGRectGetWidth(contentBounds) - padding * 2,
                                   titleHeight
                                   );
    self.titleLabel.frame = titleFrame;
    
    // Image area
    CGRect imageBounds = CGRectMake(
                                    padding,
                                    padding,
                                    CGRectGetWidth(contentBounds) - padding * 2,
                                    CGRectGetMinY(titleFrame) - padding * 2
                                    );
    
    UIImage *image = self.imageView.image;
    if (!image)
        return;
    
    CGSize imageSize = image.size;
    
    CGFloat hRatio = imageBounds.size.width / imageSize.width;
    CGFloat vRatio = imageBounds.size.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);
    
    CGSize scaledSize = CGSizeMake(floorf(imageSize.width * ratio), floorf(imageSize.height * ratio));
    
    CGRect imageFrame;
    imageFrame.size = scaledSize;
    imageFrame.origin.x = CGRectGetMidX(imageBounds) - scaledSize.width * 0.5f;
    imageFrame.origin.y = CGRectGetMidY(imageBounds) - scaledSize.height * 0.5f;
    
    self.imageView.frame = imageFrame;
}

@end
