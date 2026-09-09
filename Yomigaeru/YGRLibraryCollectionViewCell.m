//
//  YGRLibraryCollectionViewCell.m
//  Yomigaeru
//

#import "YGRLibraryCollectionViewCell.h"
#import "YGRLibraryCellContentView.h"

@interface YGRLibraryCollectionViewCell ()

@property (nonatomic, strong) YGRLibraryCellContentView *contentContainer;

@end

@implementation YGRLibraryCollectionViewCell

@dynamic image, title, unreadCount;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    _contentContainer = [[YGRLibraryCellContentView alloc] initWithFrame:self.contentView.bounds];
    _contentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_contentContainer];

    return self;
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.contentContainer reset];
}

#pragma mark - YGRLibraryCellDisplaying

- (UIImage *)image
{
    return self.contentContainer.image;
}

- (void)setImage:(UIImage *)image
{
    self.contentContainer.image = image;
}

- (NSString *)title
{
    return self.contentContainer.title;
}

- (void)setTitle:(NSString *)title
{
    self.contentContainer.title = title;
}

- (NSInteger)unreadCount
{
    return self.contentContainer.unreadCount;
}

- (void)setUnreadCount:(NSInteger)unreadCount
{
    self.contentContainer.unreadCount = unreadCount;
}

- (void)hideBorder
{
    [self.contentContainer hideBorder];
}

- (void)showBorder
{
    [self.contentContainer showBorder];
}

- (void)showLoadingSpinner
{
    [self.contentContainer showLoadingSpinner];
}

- (void)hideLoadingSpinner
{
    [self.contentContainer hideLoadingSpinner];
}

#pragma mark - Selection Appearance

// UICollectionViewCell has no AQGridViewCellSelectionStyle equivalent, so
// approximate the old blue-gray flash directly.
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.contentContainer.backgroundColor =
        highlighted ? [UIColor colorWithWhite:0.7 alpha:0.4] : [UIColor clearColor];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentContainer.frame = self.contentView.bounds;
}

@end
