//
//  YGRMangaSplitViewController.m
//  Yomigaeru
//

#import "YGRMangaSplitViewController.h"

#import "YGRMangaViewController.h"
#import "YGRMangaInfoViewController.h"

// Left (info) : right (chapters) = 2 : 3.
static const CGFloat kYGRMangaSplitLeftRatio = 2.0f / 5.0f;

@interface YGRMangaSplitViewController ()

@property (nonatomic, strong) YGRMangaViewController *mangaViewController;
@property (nonatomic, strong) YGRMangaInfoViewController *infoViewController;

@property (nonatomic, strong) UINavigationController *masterNavigationController;
@property (nonatomic, strong) UINavigationController *detailNavigationController;
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation YGRMangaSplitViewController

#pragma mark - Init

- (instancetype)initWithManga:(YGRManga *)manga
{
    self = [super init];
    if (self)
    {
        _mangaViewController = [[YGRMangaViewController alloc] init];
        _mangaViewController.manga = manga;
        _mangaViewController.hidesInfoButton = YES;
        _mangaViewController.doneTarget = self;
        _mangaViewController.doneAction = @selector(close);

        _infoViewController = [[YGRMangaInfoViewController alloc] init];
        _infoViewController.mangaId = manga.id_;

        _masterNavigationController =
            [[UINavigationController alloc] initWithRootViewController:_mangaViewController];
        _detailNavigationController =
            [[UINavigationController alloc] initWithRootViewController:_infoViewController];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    // Info (detail) on the left.
    [self addChildViewController:self.detailNavigationController];
    [self.view addSubview:self.detailNavigationController.view];
    [self.detailNavigationController didMoveToParentViewController:self];

    self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    [self.view addSubview:self.separatorView];

    // Chapters (master) on the right.
    [self addChildViewController:self.masterNavigationController];
    [self.view addSubview:self.masterNavigationController.view];
    [self.masterNavigationController didMoveToParentViewController:self];
}

/**
 *  Recomputes the left/right pane frames from the current bounds on every
 *  layout pass (initial layout and rotation alike), so the 2:3 ratio holds
 *  exactly rather than approximating it with autoresizing masks.
 */
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect bounds = self.view.bounds;
    CGFloat leftWidth = floorf(bounds.size.width * kYGRMangaSplitLeftRatio);

    self.detailNavigationController.view.frame = CGRectMake(0, 0, leftWidth, bounds.size.height);
    self.separatorView.frame = CGRectMake(leftWidth, 0, 1.0f, bounds.size.height);
    self.masterNavigationController.view.frame =
        CGRectMake(leftWidth + 1.0f, 0, bounds.size.width - leftWidth - 1.0f, bounds.size.height);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Dismissal

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
