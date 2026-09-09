//
//  YGRPullToRefreshView.m
//  Yomigaeru
//
//  Created by John Connery on 9/4/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import "YGRPullToRefreshView.h"

static const CGFloat kYGRPullToRefreshHeight = 60.0f;
static const CGFloat kYGRPullToRefreshSpinnerSpacing = 8.0f;
static const NSTimeInterval kYGRPullToRefreshInsetAnimationDuration = 0.2;

typedef NS_ENUM(NSInteger, YGRPullToRefreshState) {
    YGRPullToRefreshStateIdle,
    YGRPullToRefreshStatePulling,
    YGRPullToRefreshStateLoading
};

@interface YGRPullToRefreshView ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat originalTopInset;
@property (nonatomic, assign) YGRPullToRefreshState state;

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// iOS 6+ only: when set, this object is just a thin wrapper around a real
// UIRefreshControl instead of driving the custom header view above.
@property (nonatomic, strong) UIRefreshControl *nativeRefreshControl;

@end

@implementation YGRPullToRefreshView

#pragma mark - Initialization

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    CGRect frame = CGRectMake(0.0f, -kYGRPullToRefreshHeight, scrollView.bounds.size.width,
                               kYGRPullToRefreshHeight);

    self = [super initWithFrame:frame];
    if (self)
    {
        _scrollView = scrollView;
        _originalTopInset = scrollView.contentInset.top;
        _state = YGRPullToRefreshStateIdle;

        if (NSClassFromString(@"UIRefreshControl"))
        {
            [self configureNativeRefreshControl];
        }
        else
        {
            [self configureCustomHeaderView];
        }
    }
    return self;
}

/**
 *  iOS 6+: wraps a real `UIRefreshControl`. `UIScrollView.refreshControl`
 *  (which would otherwise wire this up automatically) wasn't added until
 *  iOS 10, and `AQGridView` is a `UIScrollView` subclass rather than a
 *  `UITableView`/`UICollectionView` to begin with, so this uses the
 *  approach that predates that property entirely: add the control as a
 *  plain scroll view subview and drive it via
 *  `UIControlEventValueChanged`. It tracks the user's pull itself, so
 *  -scrollViewDidScroll/-scrollViewDidEndDragging are no-ops in this mode.
 */
- (void)configureNativeRefreshControl
{
    self.nativeRefreshControl = [[UIRefreshControl alloc] init];
    [self.nativeRefreshControl addTarget:self
                                   action:@selector(nativeRefreshControlValueChanged)
                         forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.nativeRefreshControl];
}

- (void)nativeRefreshControlValueChanged
{
    [self.delegate pullToRefreshViewDidTriggerRefresh:self];
}

/**
 *  iOS 5 fallback: builds the "Pull to refresh" / "Release to refresh"
 *  header view and adds it above the scroll view's content.
 */
- (void)configureCustomHeaderView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:13.0f];
    self.statusLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.statusLabel];

    self.spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    [self addSubview:self.spinner];

    [self updateForState:self.state];

    [self.scrollView addSubview:self];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.statusLabel sizeToFit];
    CGSize labelSize = self.statusLabel.bounds.size;
    CGSize spinnerSize = self.spinner.bounds.size;

    BOOL showsSpinner = (self.state == YGRPullToRefreshStateLoading);
    CGFloat spacing = showsSpinner ? kYGRPullToRefreshSpinnerSpacing : 0.0f;
    CGFloat totalWidth = labelSize.width + (showsSpinner ? spinnerSize.width + spacing : 0.0f);
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2.0f;

    if (showsSpinner)
    {
        self.spinner.frame = CGRectMake(startX, (self.bounds.size.height - spinnerSize.height) / 2.0f,
                                         spinnerSize.width, spinnerSize.height);
        startX = CGRectGetMaxX(self.spinner.frame) + spacing;
    }

    self.statusLabel.frame = CGRectMake(startX, 0.0f, labelSize.width, self.bounds.size.height);
}

#pragma mark - State

/**
 *  Updates the status text and spinner animation for the given state, then
 *  re-lays-out to account for the spinner only occupying space while
 *  loading.
 */
- (void)updateForState:(YGRPullToRefreshState)state
{
    switch (state)
    {
        case YGRPullToRefreshStateIdle:
            self.statusLabel.text = @"Pull to refresh";
            [self.spinner stopAnimating];
            break;

        case YGRPullToRefreshStatePulling:
            self.statusLabel.text = @"Release to refresh";
            [self.spinner stopAnimating];
            break;

        case YGRPullToRefreshStateLoading:
            self.statusLabel.text = @"Refreshing…";
            [self.spinner startAnimating];
            break;
    }

    [self setNeedsLayout];
}

- (void)setState:(YGRPullToRefreshState)state
{
    if (_state == state)
    {
        return;
    }

    _state = state;
    [self updateForState:state];
}

#pragma mark - Scroll Tracking

- (void)scrollViewDidScroll
{
    if (self.nativeRefreshControl || self.state == YGRPullToRefreshStateLoading
        || !self.scrollView.isDragging)
    {
        return;
    }

    CGFloat pullDistance = -(self.scrollView.contentOffset.y + self.originalTopInset);

    if (pullDistance > kYGRPullToRefreshHeight)
    {
        self.state = YGRPullToRefreshStatePulling;
    }
    else
    {
        self.state = YGRPullToRefreshStateIdle;
    }
}

- (void)scrollViewDidEndDragging
{
    if (self.nativeRefreshControl || self.state != YGRPullToRefreshStatePulling)
    {
        return;
    }

    self.state = YGRPullToRefreshStateLoading;

    UIScrollView *scrollView = self.scrollView;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kYGRPullToRefreshInsetAnimationDuration
                     animations:^{
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         if (!strongSelf) return;
                         UIEdgeInsets insets = scrollView.contentInset;
                         insets.top = strongSelf.originalTopInset + kYGRPullToRefreshHeight;
                         scrollView.contentInset = insets;
                     }];

    [self.delegate pullToRefreshViewDidTriggerRefresh:self];
}

- (void)finishLoading
{
    if (self.nativeRefreshControl)
    {
        [self.nativeRefreshControl endRefreshing];
        return;
    }

    if (self.state != YGRPullToRefreshStateLoading)
    {
        return;
    }

    UIScrollView *scrollView = self.scrollView;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kYGRPullToRefreshInsetAnimationDuration
        animations:^{
            UIEdgeInsets insets = scrollView.contentInset;
            insets.top = weakSelf.originalTopInset;
            scrollView.contentInset = insets;
        }
        completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.state = YGRPullToRefreshStateIdle;
        }];
}

@end
