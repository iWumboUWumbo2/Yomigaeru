//
//  YGRLibraryCell.m
//  Yomigaeru
//

#import "YGRLibraryCell.h"
#import <QuartzCore/QuartzCore.h>

@interface YGRLibraryCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation YGRLibraryCell

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // Image view
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = YES;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _imageView.layer.borderWidth = 0.0f;
    _imageView.layer.borderColor = [UIColor blueColor].CGColor;
    [self.contentView addSubview:_imageView];
    
    // Gradient at bottom
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[
        (id)[UIColor clearColor].CGColor,
        (id)[UIColor blackColor].CGColor
    ];
    _gradientLayer.locations = @[@0.0, @1.0];
    [_imageView.layer addSublayer:_gradientLayer];
    
    // Title label on top of gradient
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textAlignment = UITextAlignmentLeft; // left-aligned
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_imageView addSubview:_titleLabel];
    
    return self;
}


#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.titleLabel.text = nil;
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

- (void)hideBorder
{
    self.imageView.layer.borderWidth = 0.0f;
}

- (void)showBorder
{
    self.imageView.layer.borderWidth = 2.0f;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGFloat padding = 4.0;
    
    // Image takes almost the full cell
    self.imageView.frame = CGRectInset(bounds, padding, padding);
    
    // Maintain 2:3 aspect ratio
    CGFloat desiredRatio = 4.0 / 5.0;
    CGFloat imageWidth = CGRectGetWidth(self.imageView.frame);
    CGFloat imageHeight = imageWidth / desiredRatio;
    
    if (imageHeight > CGRectGetHeight(self.imageView.frame)) {
        imageHeight = CGRectGetHeight(self.imageView.frame);
        imageWidth = imageHeight * desiredRatio;
    }
    
    CGFloat imageX = (CGRectGetWidth(bounds) - imageWidth) / 2.0;
    CGFloat imageY = padding;
    self.imageView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight);
    
    // Gradient covers bottom ~35% of image
    CGFloat gradientHeight = imageHeight * 0.35;
    self.gradientLayer.frame = CGRectMake(0,
                                          imageHeight - gradientHeight,
                                          imageWidth,
                                          gradientHeight);
    
    // Title left-aligned with some inner padding
    CGFloat titlePadding = 6.0; // padding from left and right
    self.titleLabel.frame = CGRectMake(titlePadding,
                                       imageHeight - gradientHeight + titlePadding,
                                       imageWidth - 2 * titlePadding,
                                       gradientHeight);
}

@end
