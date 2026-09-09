//
//  YGRLibraryCellContentView.h
//  Yomigaeru
//
//  Created by John Connery on 2026/09/09.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRLibraryCellDisplaying.h"

/**
 *  Renders a manga cover thumbnail with its title overlaid on a bottom
 *  gradient, an optional unread-count badge, a selectable border to mark
 *  library membership, and a loading spinner for the thumbnail fetch.
 *
 *  This holds the actual visual implementation shared by YGRLibraryCell
 *  (AQGridView, iOS 5) and YGRLibraryCollectionViewCell (UICollectionView,
 *  iOS 6+), which each embed an instance of this view inside their own
 *  content view so the two grid technologies render identically.
 */
@interface YGRLibraryCellContentView : UIView <YGRLibraryCellDisplaying>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger unreadCount;

/** Resets all displayed content back to its default (unpopulated) state. */
- (void)reset;

@end
