//
//  YGRTabBarController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRTabBarController.h"
#import "YGRLibraryViewController.h"

@interface YGRTabBarController ()

@end

@implementation YGRTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupTabs
{
    YGRLibraryViewController *libraryViewController = [[YGRLibraryViewController alloc] initWithStyle:UITableViewStylePlain];    
    UINavigationController *libraryNavigationController = [[UINavigationController alloc] initWithRootViewController:libraryViewController];
    libraryViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Library" image:nil tag:0];
    
    [self setViewControllers:@[ libraryNavigationController ]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupTabs];
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
