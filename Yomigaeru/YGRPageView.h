//
//  YGRPageView.h
//  Yomigaeru
//
//  Created by John Connery on 9/4/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGRPageView;

/**
 *  The parent (scroll view controller owning the 3 sliding slots) implements
 *  this to be told about load failures. YGRPageView has no navigation
 *  context of its own, so it can't present an alert or dismiss anything
 *  itself.
 */
@protocol YGRPageViewDelegate <NSObject>

- (void)pageView:(YGRPageView *)pageView didFailToLoadWithError:(NSError *)error;

@end

/**
 *  Displays a single manga page image in a zoomable scroll view, fetching
 *  the image on demand and reporting load failures via an alert.
 */
@interface YGRPageView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<YGRPageViewDelegate> delegate;

#pragma mark - Configuration

/** The id of the manga this page belongs to. */
@property (nonatomic, copy) NSString *mangaId;

/** The 1-based index of the chapter this page belongs to. */
@property (nonatomic, assign) NSInteger chapterIndex;
/** The 0-based index of this page within its chapter. */
@property (nonatomic, assign) NSInteger pageIndex;

/**
 *  (Re)configures this slot for a specific page and kicks off the image
 *  load. Safe to call on a slot that's already showing a different page —
 *  any in-flight load for the previous page is invalidated so its
 *  completion can't land on this slot after reassignment.
 */
- (void)configureWithMangaId:(NSString *)mangaId
                chapterIndex:(NSUInteger)chapterIndex
                   pageIndex:(NSInteger)pageIndex;

/**
 *  Resets zoom/image/loading state without starting a new load. Useful when
 *  temporarily parking a slot (e.g. it's about to be reassigned and you
 *  want to clear stale content first).
 */
- (void)prepareForReuse;

@end
