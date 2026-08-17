//
//  YGRExtensionInfoViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGRExtension.h"

/**
 *  A grouped-style, read-only detail screen showing an extension's icon,
 *  name, package name, version, and language.
 */
@interface YGRExtensionInfoViewController : UITableViewController

#pragma mark - Configuration

/** The extension whose details are being displayed. */
@property (nonatomic, strong) YGRExtension *extension;
/** The extension's icon image, pre-fetched by the presenting list so it doesn't need to be re-fetched here. */
@property (nonatomic, strong) UIImage *thumbnailImage;

@end
