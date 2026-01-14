//
//  YGRBrowseContainerViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRBrowseViewController.h"

#import "YGRSourcesViewController.h"
#import "YGRExtensionsViewController.h"

@interface YGRBrowseViewController ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *viewControllerSegmentedControl;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *viewControllerTitles;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation YGRBrowseViewController

- (id)init
{
    self = [super init];
    if (self) {
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

- (void)cycleToNewViewController:(UIViewController *)newViewController
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
    
    [self transitionFromViewController:self.currentViewController toViewController:newViewController duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        [self.currentViewController removeFromParentViewController];
        [newViewController didMoveToParentViewController:self];
        self.currentViewController = newViewController;
    }];
}

- (void)configureViewControllerSegmentedControl
{
    self.viewControllerSegmentedControl = [[UISegmentedControl alloc] initWithItems:self.viewControllerTitles];
    
    self.viewControllerSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.viewControllerSegmentedControl addTarget:self action:@selector(viewControllerDidChange:) forControlEvents:UIControlEventValueChanged];
    self.viewControllerSegmentedControl.selectedSegmentIndex = 0;
    
    CGFloat padding = 8.0f;
    CGFloat height  = 32.0f;
    
    self.viewControllerSegmentedControl.frame = CGRectMake(padding, padding, self.view.bounds.size.width - (padding * 2), height);
    
    self.viewControllerSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.viewControllerSegmentedControl];
}

- (void)viewControllerDidChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex < 0 || sender.selectedSegmentIndex >= self.viewControllers.count)
    {
        return;
    }
    
    UIViewController *newViewController = [self.viewControllers objectAtIndex:sender.selectedSegmentIndex];
    [self cycleToNewViewController:newViewController];
}

- (void)configureContentView
{    
    CGFloat top = CGRectGetMaxY(self.viewControllerSegmentedControl.frame) + 8.0f;
    
    CGRect contentViewFrame = CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top);
    self.contentView = [[UIView alloc] initWithFrame:contentViewFrame];
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    [self.view addSubview:self.contentView];
}

- (void)configureViewControllers
{
    YGRSourcesViewController *sourcesViewController = [[YGRSourcesViewController alloc] init];
    YGRExtensionsViewController *extensionsViewController = [[YGRExtensionsViewController alloc] init];
    
    self.viewControllers = @[ sourcesViewController, extensionsViewController ];
    self.viewControllerTitles = @[ @"Sources", @"Extensions" ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.title = @"Browse";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureViewControllers];
    [self configureViewControllerSegmentedControl];
    [self configureContentView];
    
    self.currentViewController = [self.viewControllers objectAtIndex:0];
    [self displayViewController:self.currentViewController];
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
