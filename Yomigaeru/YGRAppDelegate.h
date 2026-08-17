//
//  YGRAppDelegate.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGRViewController;

/**
 *  The application delegate. Sets up the app's window and installs
 *  `YGRTabBarController` as its root view controller on launch.
 */
@interface YGRAppDelegate : UIResponder <UIApplicationDelegate>

#pragma mark - Properties

/** The application's main window. */
@property (strong, nonatomic) UIWindow *window;

/** Unused; retained for compatibility with the Xcode-generated template. */
@property (strong, nonatomic) YGRViewController *viewController;

@end
