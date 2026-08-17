//
//  YGRLibraryCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "AQGridViewCell.h"
#import <UIKit/UIKit.h>

/**
 *  A grid cell showing a manga's cover thumbnail with its title overlaid on
 *  a bottom gradient, an optional unread-count badge, a selectable border to
 *  mark library membership, and a loading spinner for the thumbnail fetch.
 */
@interface YGRLibraryCell : AQGridViewCell

#pragma mark - Properties

/** The cover thumbnail image. Assigning triggers a layout pass. */
@property (nonatomic, strong) UIImage *image;

/** The manga title shown over the bottom gradient. Assigning triggers a layout pass. */
@property (nonatomic, copy) NSString *title;

/**
 *  The number shown in the unread badge. Values <= 0 hide the badge;
 *  positive values show it and set its label text.
 */
@property (nonatomic, assign) NSInteger unreadCount;

#pragma mark - Border

/** Hides the border used to indicate the manga is in the user's library. */
- (void)hideBorder;

/** Shows the border used to indicate the manga is in the user's library. */
- (void)showBorder;

#pragma mark - Loading Spinner

/** Starts the thumbnail-loading spinner. */
- (void)showLoadingSpinner;

/** Stops the thumbnail-loading spinner. */
- (void)hideLoadingSpinner;

@end
