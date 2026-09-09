//
//  YGRLibraryCellDisplaying.h
//  Yomigaeru
//
//  Created by John Connery on 2026/09/09.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Common display interface implemented by both YGRLibraryCell (the
 *  AQGridView-backed cell used on iOS 5) and YGRLibraryCollectionViewCell
 *  (the UICollectionView-backed cell used on iOS 6+), so callers can
 *  configure whichever one is active identically.
 */
@protocol YGRLibraryCellDisplaying <NSObject>

/** The cover thumbnail image. Assigning triggers a layout pass. */
@property (nonatomic, strong) UIImage *image;

/** The manga title shown over the bottom gradient. Assigning triggers a layout pass. */
@property (nonatomic, copy) NSString *title;

/**
 *  The number shown in the unread badge. Values <= 0 hide the badge;
 *  positive values show it and set its label text.
 */
@property (nonatomic, assign) NSInteger unreadCount;

/** Hides the border used to indicate the manga is in the user's library. */
- (void)hideBorder;

/** Shows the border used to indicate the manga is in the user's library. */
- (void)showBorder;

/** Starts the thumbnail-loading spinner. */
- (void)showLoadingSpinner;

/** Stops the thumbnail-loading spinner. */
- (void)hideLoadingSpinner;

@end
