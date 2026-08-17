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

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

#pragma mark - Child View Controller Management

/**
 *  Adds the given view controller as a child, sizes its view to fill the
 *  content view, and completes the containment transition.
 *
 *  @param viewController The child view controller to display.
 */
- (void)displayViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    viewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:viewController.view];
    viewController.view.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController didMoveToParentViewController:self];
}

/**
 *  Swaps the currently displayed child view controller for a new one using
 *  the container transition APIs. Does nothing if `newViewController` is
 *  already the current one.
 *
 *  @param newViewController The child view controller to make current.
 */
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

#pragma mark - UI Configuration

/**
 *  Builds and positions the segmented control used to switch between the
 *  Sources and Extensions child view controllers.
 */
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

/**
 *  Builds the search bar and its delegate proxy, sized to match the
 *  segmented control's frame. Not added to the view here; it is swapped in
 *  when the search button is tapped.
 */
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

#pragma mark - Search Bar

/**
 *  Routes the proxy's search callbacks to the current child, then swaps the
 *  segmented control out for the search bar and focuses it.
 */
- (void)showSearchBar
{
    self.searchBarDelegateProxy.searchHandler = self.currentViewController;
    
    [self.viewControllerSegmentedControl removeFromSuperview];
    [self.view addSubview:self.searchBar];
    [self.searchBar becomeFirstResponder];
}

/**
 *  Swaps the search bar out for the segmented control.
 */
- (void)hideSearchBar
{
    [self.searchBar removeFromSuperview];
    [self.view addSubview:self.viewControllerSegmentedControl];
}

#pragma mark - Search bar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchBar];
//    [self mangaListDidChange:self.mangaListSegmentedControl];
}

#pragma mark - Segmented Control

/**
 *  Handles a segmented control value change by cycling to the corresponding
 *  child view controller and clearing the refresh spinner.
 *
 *  @param sender The segmented control that changed value.
 */
- (void)viewControllerDidChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex < 0 ||
        sender.selectedSegmentIndex >= self.viewControllers.count)
    {
        return;
    }

    UIViewController<YGRRefreshable, UISearchBarDelegate> *newViewController =
        self.viewControllers[sender.selectedSegmentIndex];
    [self cycleToNewViewController:newViewController];
    [self disableSpinner];
}

#pragma mark - Content Setup

/**
 *  Builds the container view that hosts the current child view controller's
 *  view, positioned below the segmented control.
 */
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

/**
 *  Instantiates the Sources and Extensions child view controllers and sets
 *  self as their refresh delegate.
 */
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

#pragma mark - Spinner

/**
 *  Replaces the refresh bar button item with an animating spinner, if not
 *  already animating.
 */
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

/**
 *  Stops the spinner and restores the refresh bar button item, if it was
 *  animating.
 */
- (void)disableSpinner
{
    if ([self.refreshSpinner isAnimating])
    {
        [self.refreshSpinner stopAnimating];
        self.navigationItem.leftBarButtonItem = self.refreshButton;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

#pragma mark - Refresh

/**
 *  Enables the spinner and asks the current child view controller to
 *  refresh itself; invoked by the refresh bar button item.
 */
- (void)refreshLibrary
{
    [self enableSpinner];
    [self.currentViewController refresh];
}

#pragma mark - YGRChildRefreshDelegate

/**
 *  Stops the refresh spinner once the active child reports that it has
 *  finished refreshing.
 */
- (void)childDidFinishRefreshing
{
    [self disableSpinner];
}

#pragma mark - Lifecycle

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

    self.currentViewController = self.viewControllers[0];
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
