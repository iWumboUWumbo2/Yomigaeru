//
//  YGRBrowseContainerViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRBrowseViewController.h"

#import "YGRExtensionsViewController.h"
#import "YGRSourcesViewController.h"
#import "YGRBrowseSearchBarDelegateProxy.h"

@interface YGRBrowseViewController ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *viewControllerSegmentedControl;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) YGRBrowseSearchBarDelegateProxy *searchBarDelegateProxy;

@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *viewControllerTitles;
@property (nonatomic, strong) UIViewController<YGRRefreshable, UISearchBarDelegate> *currentViewController;

@end

@implementation YGRBrowseViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)displayViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    viewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:viewController.view];
    viewController.view.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController didMoveToParentViewController:self];
}

- (void)cycleToNewViewController:(UIViewController<YGRRefreshable, UISearchBarDelegate> *)newViewController
{
    if (!self.currentViewController)
    {
        self.currentViewController = newViewController;
        [self displayViewController:newViewController];
        return;
    }

    if (self.currentViewController == newViewController)
    {
        return;
    }

    // Prepare the two view controllers for the change.
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:newViewController];

    // Get the start frame of the new view controller and the end frame
    // for the old view controller. Both rectangles are offscreen.
    newViewController.view.frame = self.currentViewController.view.frame;
    newViewController.view.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self transitionFromViewController:self.currentViewController
                      toViewController:newViewController
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:nil
                            completion:^(BOOL finished) {
                                [self.currentViewController removeFromParentViewController];
                                [newViewController didMoveToParentViewController:self];
                                self.currentViewController = newViewController;
                            }];
}

- (void)configureViewControllerSegmentedControl
{
    self.viewControllerSegmentedControl =
        [[UISegmentedControl alloc] initWithItems:self.viewControllerTitles];

    self.viewControllerSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.viewControllerSegmentedControl addTarget:self
                                            action:@selector(viewControllerDidChange:)
                                  forControlEvents:UIControlEventValueChanged];
    self.viewControllerSegmentedControl.selectedSegmentIndex = 0;

    CGFloat padding = 8.0f;
    CGFloat height = 32.0f;

    self.viewControllerSegmentedControl.frame =
        CGRectMake(padding, padding, self.view.bounds.size.width - (padding * 2), height);

    self.viewControllerSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.viewControllerSegmentedControl];
}

- (void)configureSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.viewControllerSegmentedControl.frame];
    self.searchBar.barStyle = UIBarStyleBlackTranslucent;
    self.searchBar.showsCancelButton = YES;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.searchBarDelegateProxy = [[YGRBrowseSearchBarDelegateProxy alloc] init];
    self.searchBarDelegateProxy.stateHandler = self;
    
    self.searchBar.delegate = self.searchBarDelegateProxy;
}

- (void)showSearchBar
{
    self.searchBarDelegateProxy.searchHandler = self.currentViewController;
    
    [self.viewControllerSegmentedControl removeFromSuperview];
    [self.view addSubview:self.searchBar];
    [self.searchBar becomeFirstResponder];
}

- (void)hideSearchBar
{
    [self.searchBar removeFromSuperview];
    [self.view addSubview:self.viewControllerSegmentedControl];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchBar];
//    [self mangaListDidChange:self.mangaListSegmentedControl];
}

- (void)viewControllerDidChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex < 0 ||
        sender.selectedSegmentIndex >= self.viewControllers.count)
    {
        return;
    }

    UIViewController<YGRRefreshable, UISearchBarDelegate> *newViewController =
        [self.viewControllers objectAtIndex:sender.selectedSegmentIndex];
    [self cycleToNewViewController:newViewController];
    [self disableSpinner];
}

- (void)configureContentView
{
    CGFloat top = CGRectGetMaxY(self.viewControllerSegmentedControl.frame) + 8.0f;

    CGRect contentViewFrame =
        CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top);
    self.contentView = [[UIView alloc] initWithFrame:contentViewFrame];

    self.contentView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.contentView];
}

- (void)configureViewControllers
{
    YGRSourcesViewController *sourcesViewController = [[YGRSourcesViewController alloc] init];
    sourcesViewController.refreshDelegate = self;

    YGRExtensionsViewController *extensionsViewController =
        [[YGRExtensionsViewController alloc] init];
    extensionsViewController.refreshDelegate = self;

    self.viewControllers = @[ sourcesViewController, extensionsViewController ];
    self.viewControllerTitles = @[ @"Sources", @"Extensions" ];
}

- (void)enableSpinner
{
    if (![self.refreshSpinner isAnimating])
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self.refreshSpinner startAnimating];
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithCustomView:self.refreshSpinner];
    }
}

- (void)disableSpinner
{
    if ([self.refreshSpinner isAnimating])
    {
        [self.refreshSpinner stopAnimating];
        self.navigationItem.leftBarButtonItem = self.refreshButton;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (void)refreshLibrary
{
    [self enableSpinner];
    [self.currentViewController refresh];
}

- (void)childDidFinishRefreshing
{
    [self disableSpinner];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = @"Browse";
    self.view.backgroundColor = [UIColor whiteColor];

    // Refresh button & spinner
    self.refreshButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                      target:self
                                                      action:@selector(refreshLibrary)];
    self.refreshSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                  target:self
                                                  action:@selector(showSearchBar)];

    [self configureViewControllers];
    [self configureViewControllerSegmentedControl];
    [self configureSearchBar];
    
    [self configureContentView];

    self.currentViewController = [self.viewControllers objectAtIndex:0];
    [self displayViewController:self.currentViewController];

    // Prevent nav bar and tab bar from overlaying the view in iOS 7.0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self disableSpinner];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
