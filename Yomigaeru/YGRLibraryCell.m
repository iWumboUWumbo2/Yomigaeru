//
//  YGRLibraryCell.m
//  Yomigaeru
//

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
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

// Container view for the top-left label background
@property (nonatomic, strong) UIView *unreadBubbleView;
@property (nonatomic, strong) UILabel *unreadLabel;

@end

@implementation YGRLibraryCell

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // --- Image view ---
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _imageView.layer.borderWidth = 0.0f;
    _imageView.layer.borderColor = [UIColor blueColor].CGColor;
    [self.contentView addSubview:_imageView];
    
    // --- Gradient at bottom ---
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[ (id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor ];
    _gradientLayer.locations = @[ @0.0, @1.0 ];
    [_imageView.layer addSublayer:_gradientLayer];
    
    // --- Title label on top of gradient ---
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_imageView addSubview:_titleLabel];
    
    // --- Unread label container ---
    _unreadBubbleView = [[UIView alloc] initWithFrame:CGRectZero];
    _unreadBubbleView.backgroundColor = [UIColor colorWithRed: 0.68 green: 0.73 blue: 0.80 alpha: 1.00];
    _unreadBubbleView.layer.cornerRadius = 10.0f;
    _unreadBubbleView.layer.masksToBounds = YES;
    _unreadBubbleView.hidden = YES; // initially hidden
    [self.contentView addSubview:_unreadBubbleView];
    
    _unreadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _unreadLabel.font = [UIFont systemFontOfSize:12.0f];
    _unreadLabel.textColor = [UIColor blackColor];
    _unreadLabel.textAlignment = NSTextAlignmentCenter;
    _unreadLabel.backgroundColor = [UIColor clearColor];
    [_unreadBubbleView addSubview:_unreadLabel];
    
    // --- Loading spinner ---
    _loadingSpinner = [[UIActivityIndicatorView alloc]
                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingSpinner.hidesWhenStopped = YES;
    [_imageView addSubview:_loadingSpinner];
    
    return self;
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.titleLabel.text = nil;
    [self.loadingSpinner stopAnimating];
    
    self.unreadLabel.text = nil;
    self.unreadBubbleView.hidden = YES;
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

- (void)setUnreadCount:(NSInteger)unreadCount
{
    _unreadCount = unreadCount;
    
    if (unreadCount <= 0) {
        self.unreadBubbleView.hidden = YES;
        return;
    }
    
    self.unreadBubbleView.hidden = NO;
    self.unreadLabel.text = [NSString stringWithFormat:@"%ld", (long)unreadCount];
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

- (void)showLoadingSpinner
{
    [self.loadingSpinner startAnimating];
}

- (void)hideLoadingSpinner
{
    [self.loadingSpinner stopAnimating];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGFloat padding = 4.0;
    
    // --- Image frame ---
    self.imageView.frame = CGRectInset(bounds, padding, padding);
    
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
    
    // --- Unread label layout ---
    if (!self.unreadBubbleView.hidden) {
        CGFloat minSize = 20.0f;
        CGFloat padding = 6.0f;
        
        CGSize textSize = [self.unreadLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, minSize)];
        CGFloat width = MAX(minSize, textSize.width + padding);
        
        self.unreadBubbleView.frame =
        CGRectMake(CGRectGetMinX(self.imageView.frame) + 6.0f,
                   CGRectGetMinY(self.imageView.frame) + 6.0f,
                   width,
                   minSize);
        
        self.unreadBubbleView.layer.cornerRadius = minSize / 3.0f;
        self.unreadLabel.frame = self.unreadBubbleView.bounds;
    }
    
    // --- Gradient at bottom ---
    CGFloat gradientHeight = imageHeight * 0.35;
    self.gradientLayer.frame = CGRectMake(0, imageHeight - gradientHeight, imageWidth, gradientHeight);
    
    // --- Title label ---
    CGFloat titlePadding = 6.0;
    self.titleLabel.frame = CGRectMake(titlePadding,
                                       imageHeight - gradientHeight + titlePadding,
                                       imageWidth - 2 * titlePadding,
                                       gradientHeight);
    
    // --- Spinner ---
    self.loadingSpinner.center = CGPointMake(imageWidth / 2.0f, imageHeight / 2.0f);
    
    // --- Bring unread label container to front ---
    [self.imageView bringSubviewToFront:self.unreadBubbleView];
}

@end
