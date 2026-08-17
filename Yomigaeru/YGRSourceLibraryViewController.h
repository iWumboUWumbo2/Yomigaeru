//
//  YGRSourceLibraryViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/16.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSource.h"
#import <UIKit/UIKit.h>

/**
 *  Displays a single source's manga catalog (popular and latest lists) in a
 *  grid, with search and library-toggling support.
 */
@interface YGRSourceLibraryViewController : UIViewController

#pragma mark - Configuration

/**
 *  The source whose manga lists this controller displays. Setting this also
 *  updates the underlying view model.
 */
@property (nonatomic, strong) YGRSource *source;

#pragma mark - Initialization

/**
 *  Creates a source library view controller, sizing its grid cells from the
 *  current screen width and device idiom.
 *
 *  @return A newly initialized source library view controller.
 */
- (instancetype)init;

@end
