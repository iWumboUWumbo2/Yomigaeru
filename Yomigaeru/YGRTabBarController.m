//
//  YGRTabBarController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRTabBarController.h"

#import "YGRBrowseViewController.h"
#import "YGRLibraryViewController.h"
#import "YGRSettingsViewController.h"

@interface YGRTabBarController ()

@end

@implementation YGRTabBarController

#pragma mark - Configuration

/**
 *  Builds the Library, Browse, and Settings tabs, each wrapped in its own
 *  navigation controller, and installs them as this controller's view
 *  controllers.
 */
- (void)setupTabs
{
    YGRLibraryViewController *libraryViewController = [[YGRLibraryViewController alloc] init];
    UIImage *libraryIcon = [UIImage imageNamed:@"library"];
    UINavigationController *libraryNavigationController =
        [[UINavigationController alloc] initWithRootViewController:libraryViewController];
    libraryNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Library"
                                                                           image:libraryIcon
                                                                             tag:0];

    YGRBrowseViewController *browseViewController = [[YGRBrowseViewController alloc] init];
    UIImage *browseIcon = [UIImage imageNamed:@"browse"];
    UINavigationController *browseNavigationController =
        [[UINavigationController alloc] initWithRootViewController:browseViewController];
    browseNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Browse"
                                                                          image:browseIcon
                                                                            tag:1];

    YGRSettingsViewController *settingsViewController = [[YGRSettingsViewController alloc] init];
    UIImage *settingsIcon = [UIImage imageNamed:@"settings"];
    UINavigationController *settingsNavigationController =
        [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                                            image:settingsIcon
                                                                              tag:2];

    [self setViewControllers:@[
        libraryNavigationController, browseNavigationController, settingsNavigationController
    ]];
}

#pragma mark - Lifecycle

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
