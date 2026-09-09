//
//  YGRLibraryCollectionViewCell.h
//  Yomigaeru
//
//  Created by John Connery on 2026/09/09.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRLibraryCellDisplaying.h"

/**
 *  The UICollectionView-backed library cell used on iOS 6+. See
 *  YGRLibraryCellContentView for the actual visual implementation, which
 *  this cell embeds and forwards to; YGRLibraryCell is the AQGridView-backed
 *  counterpart used on iOS 5.
 */
@interface YGRLibraryCollectionViewCell : UICollectionViewCell <YGRLibraryCellDisplaying>

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
