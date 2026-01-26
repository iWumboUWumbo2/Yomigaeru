//
//  YGRMangaInfoViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/26.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRMangaInfoViewController.h"

#import "YGRImageService.h"
#import "YGRMangaService.h"
#import "YGRMangaStatusUtility.h"

@interface YGRMangaInfoViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) YGRManga *manga;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIActivityIndicatorView *thumbnailSpinner;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *genresContainerView;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@end

@implementation YGRMangaInfoViewController

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _mangaService = [[YGRMangaService alloc] init];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Info";
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupScrollView];
    [self setupContentViews];
    [self setupLoadingSpinner];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchMangaInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Setup

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrollView addSubview:self.contentView];
}

- (void)setupContentViews
{
    CGFloat padding = 16.0f;
    CGFloat viewWidth = self.view.bounds.size.width;

    // Thumbnail image view
    CGFloat thumbnailSize = 150.0f;
    self.thumbnailImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth - thumbnailSize) / 2.0f, padding,
                                                      thumbnailSize, thumbnailSize * 1.4f)];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImageView.clipsToBounds = YES;
    self.thumbnailImageView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    self.thumbnailImageView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:self.thumbnailImageView];

    // Thumbnail spinner
    self.thumbnailSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.thumbnailSpinner.hidesWhenStopped = YES;
    self.thumbnailSpinner.center = CGPointMake(thumbnailSize / 2.0f, (thumbnailSize * 1.4f) / 2.0f);
    [self.thumbnailImageView addSubview:self.thumbnailSpinner];

    CGFloat yOffset = CGRectGetMaxY(self.thumbnailImageView.frame) + padding;

    // Title label
    self.titleLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 0)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.titleLabel];

    yOffset += padding;

    // Author label
    self.authorLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 20)];
    self.authorLabel.font = [UIFont systemFontOfSize:14.0f];
    self.authorLabel.textColor = [UIColor darkGrayColor];
    self.authorLabel.textAlignment = UITextAlignmentCenter;
    self.authorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.authorLabel];

    yOffset += 24;

    // Artist label
    self.artistLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 20)];
    self.artistLabel.font = [UIFont systemFontOfSize:14.0f];
    self.artistLabel.textColor = [UIColor darkGrayColor];
    self.artistLabel.textAlignment = UITextAlignmentCenter;
    self.artistLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.artistLabel];

    yOffset += 24;

    // Status label
    self.statusLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 24)];
    self.statusLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.textAlignment = UITextAlignmentCenter;
    self.statusLabel.backgroundColor = [UIColor colorWithRed:0.2f green:0.6f blue:0.2f alpha:1.0f];
    self.statusLabel.layer.cornerRadius = 4.0f;
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.statusLabel];

    yOffset += 32;

    // Genres container
    self.genresContainerView =
        [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 0)];
    self.genresContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.genresContainerView];

    yOffset += padding;

    // Description header
    UILabel *descriptionHeader =
        [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 24)];
    descriptionHeader.font = [UIFont boldSystemFontOfSize:16.0f];
    descriptionHeader.text = @"Description";
    descriptionHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:descriptionHeader];

    yOffset += 28;

    // Description label
    self.descriptionLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, viewWidth - padding * 2, 0)];
    self.descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
    self.descriptionLabel.textColor = [UIColor darkGrayColor];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.descriptionLabel];
}

- (void)setupLoadingSpinner
{
    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.loadingSpinner.center =
        CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    [self.view addSubview:self.loadingSpinner];
}

#pragma mark - Data Fetching

- (void)fetchMangaInfo
{
    [self.loadingSpinner startAnimating];
    self.scrollView.hidden = YES;

    __weak typeof(self) weakSelf = self;
    [self.mangaService fetchFullMangaWithId:self.mangaId
                                 completion:^(YGRManga *manga, NSError *error) {
                                     __strong typeof(weakSelf) strongSelf = weakSelf;
                                     if (!strongSelf)
                                         return;

                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [strongSelf.loadingSpinner stopAnimating];
                                         strongSelf.scrollView.hidden = NO;
                                     });

                                     if (error || !manga)
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             UIAlertView *alert = [[UIAlertView alloc]
                                                     initWithTitle:@"Error"
                                                           message:@"Failed to load manga info"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                                             [alert show];
                                         });
                                         return;
                                     }

                                     strongSelf.manga = manga;
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [strongSelf updateUI];
                                     });
                                 }];
}

#pragma mark - UI Updates

- (void)updateUI
{
    if (!self.manga)
        return;

    CGFloat padding = 16.0f;
    CGFloat viewWidth = self.view.bounds.size.width;

    // Update title
    self.title = self.manga.title;
    self.titleLabel.text = self.manga.title;
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.size.width = viewWidth - padding * 2;
    self.titleLabel.frame = titleFrame;

    CGFloat yOffset = CGRectGetMaxY(self.thumbnailImageView.frame) + padding;
    self.titleLabel.frame =
        CGRectMake(padding, yOffset, viewWidth - padding * 2, self.titleLabel.frame.size.height);
    yOffset = CGRectGetMaxY(self.titleLabel.frame) + 8;

    // Update author
    if (self.manga.author.length > 0)
    {
        self.authorLabel.text = [NSString stringWithFormat:@"Author: %@", self.manga.author];
        self.authorLabel.frame = CGRectMake(padding, yOffset, viewWidth - padding * 2, 20);
        self.authorLabel.hidden = NO;
        yOffset += 24;
    }
    else
    {
        self.authorLabel.hidden = YES;
    }

    // Update artist
    if (self.manga.artist.length > 0 && ![self.manga.artist isEqualToString:self.manga.author])
    {
        self.artistLabel.text = [NSString stringWithFormat:@"Artist: %@", self.manga.artist];
        self.artistLabel.frame = CGRectMake(padding, yOffset, viewWidth - padding * 2, 20);
        self.artistLabel.hidden = NO;
        yOffset += 24;
    }
    else
    {
        self.artistLabel.hidden = YES;
    }

    // Update status
    NSString *statusString = [YGRMangaStatusUtility stringFromMangaStatus:self.manga.status];
    self.statusLabel.text = [NSString stringWithFormat:@"  %@  ", statusString];
    [self.statusLabel sizeToFit];
    CGRect statusFrame = self.statusLabel.frame;
    statusFrame.origin.x = (viewWidth - statusFrame.size.width) / 2.0f;
    statusFrame.origin.y = yOffset;
    statusFrame.size.height = 24;
    self.statusLabel.frame = statusFrame;
    [self updateStatusLabelColor];
    yOffset += 32;

    // Update genres
    [self layoutGenresAtY:yOffset];
    yOffset = CGRectGetMaxY(self.genresContainerView.frame) + padding;

    // Description header (find and reposition)
    for (UIView *subview in self.contentView.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *) subview;
            if ([label.text isEqualToString:@"Description"])
            {
                label.frame = CGRectMake(padding, yOffset, viewWidth - padding * 2, 24);
                yOffset += 28;
                break;
            }
        }
    }

    // Update description
    if (self.manga.description_.length > 0)
    {
        self.descriptionLabel.text = self.manga.description_;
        self.descriptionLabel.frame = CGRectMake(padding, yOffset, viewWidth - padding * 2, 0);
        [self.descriptionLabel sizeToFit];
        CGRect descFrame = self.descriptionLabel.frame;
        descFrame.size.width = viewWidth - padding * 2;
        self.descriptionLabel.frame = descFrame;
        self.descriptionLabel.hidden = NO;
        yOffset = CGRectGetMaxY(self.descriptionLabel.frame) + padding;
    }
    else
    {
        self.descriptionLabel.hidden = YES;
    }

    // Update content size
    self.contentView.frame = CGRectMake(0, 0, viewWidth, yOffset);
    self.scrollView.contentSize = CGSizeMake(viewWidth, yOffset);

    // Fetch thumbnail
    [self fetchThumbnail];
}

- (void)updateStatusLabelColor
{
    UIColor *statusColor;
    switch (self.manga.status)
    {
    case YGRMangaStatusOngoing:
        statusColor = [UIColor colorWithRed:0.2f green:0.6f blue:0.2f alpha:1.0f]; // Green
        break;
    case YGRMangaStatusCompleted:
        statusColor = [UIColor colorWithRed:0.2f green:0.4f blue:0.8f alpha:1.0f]; // Blue
        break;
    case YGRMangaStatusCancelled:
        statusColor = [UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0f]; // Red
        break;
    case YGRMangaStatusOnHiatus:
        statusColor = [UIColor colorWithRed:0.8f green:0.6f blue:0.0f alpha:1.0f]; // Orange
        break;
    case YGRMangaStatusLicensed:
    case YGRMangaStatusPublishingFinished:
        statusColor = [UIColor colorWithRed:0.5f green:0.3f blue:0.7f alpha:1.0f]; // Purple
        break;
    default:
        statusColor = [UIColor grayColor];
        break;
    }
    self.statusLabel.backgroundColor = statusColor;
}

- (void)layoutGenresAtY:(CGFloat)startY
{
    // Remove existing genre labels
    for (UIView *subview in self.genresContainerView.subviews)
    {
        [subview removeFromSuperview];
    }

    if (!self.manga.genres || self.manga.genres.count == 0)
    {
        self.genresContainerView.frame = CGRectMake(self.genresContainerView.frame.origin.x, startY,
                                                    self.genresContainerView.frame.size.width, 0);
        return;
    }

    CGFloat padding = 16.0f;
    CGFloat tagPadding = 8.0f;
    CGFloat tagHeight = 26.0f;
    CGFloat spacing = 6.0f;
    CGFloat maxWidth = self.view.bounds.size.width - padding * 2;

    CGFloat xOffset = 0;
    CGFloat yOffset = 0;

    for (NSString *genre in self.manga.genres)
    {
        UILabel *genreLabel = [[UILabel alloc] init];
        genreLabel.text = [NSString stringWithFormat:@" %@ ", genre];
        genreLabel.font = [UIFont systemFontOfSize:12.0f];
        genreLabel.textColor = [UIColor darkGrayColor];
        genreLabel.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        genreLabel.layer.cornerRadius = 4.0f;
        genreLabel.layer.masksToBounds = YES;
        [genreLabel sizeToFit];

        CGFloat labelWidth = genreLabel.frame.size.width + tagPadding;

        // Check if we need to wrap to next line
        if (xOffset + labelWidth > maxWidth && xOffset > 0)
        {
            xOffset = 0;
            yOffset += tagHeight + spacing;
        }

        genreLabel.frame = CGRectMake(xOffset, yOffset, labelWidth, tagHeight);
        [self.genresContainerView addSubview:genreLabel];

        xOffset += labelWidth + spacing;
    }

    CGFloat containerHeight = yOffset + tagHeight;
    self.genresContainerView.frame = CGRectMake(padding, startY, maxWidth, containerHeight);
}

- (void)fetchThumbnail
{
    [self.thumbnailSpinner startAnimating];

    __weak typeof(self) weakSelf = self;
    [[YGRImageService sharedService]
        fetchThumbnailWithMangaId:self.mangaId
                       completion:^(UIImage *thumbnailImage, NSError *error) {
                           __strong typeof(weakSelf) strongSelf = weakSelf;
                           if (!strongSelf)
                               return;

                           dispatch_async(dispatch_get_main_queue(), ^{
                               [strongSelf.thumbnailSpinner stopAnimating];
                               if (!error && thumbnailImage)
                               {
                                   strongSelf.thumbnailImageView.image = thumbnailImage;
                               }
                           });
                       }];
}

@end
