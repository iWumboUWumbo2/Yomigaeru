//
//  YGRPullToRefreshView.h
//  Yomigaeru
//
//  Created by John Connery on 9/4/26.
//  Copyright (c) 2026 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGRPullToRefreshView;

/**
 *  Notified when a pull past the threshold is released, so the owner can
 *  start whatever fetch backs the scroll view it's attached to.
 */
@protocol YGRPullToRefreshDelegate <NSObject>

- (void)pullToRefreshViewDidTriggerRefresh:(YGRPullToRefreshView *)pullToRefreshView;

@end

/**
 *  Pull-to-refresh for a scroll view, on any iOS version this app supports.
 *  On iOS 6+, wraps a real `UIRefreshControl`. On iOS 5 (where
 *  `UIRefreshControl` doesn't exist, below this app's 5.0 deployment
 *  target), falls back to a custom header view parked above the scroll
 *  view's content that reveals itself as the user pulls down past the top,
 *  switching from "Pull to refresh" to "Release to refresh" once pulled
 *  past its own height. Which mode is active is decided once, at init,
 *  and is otherwise invisible to callers — the public API below behaves
 *  the same either way.
 *
 *  The owning view controller drives the iOS 5 fallback by forwarding its
 *  own `UIScrollViewDelegate` callbacks to -scrollViewDidScroll and
 *  -scrollViewDidEndDragging (both are no-ops on iOS 6+, where the real
 *  `UIRefreshControl` tracks the pull itself) — this object is never
 *  itself the scroll view's delegate, so it doesn't compete with whatever
 *  the owner already uses that delegate slot for (table/grid data source
 *  callbacks, etc).
 */
@interface YGRPullToRefreshView : UIView

@property (nonatomic, weak) id<YGRPullToRefreshDelegate> delegate;

/**
 *  Creates a pull-to-refresh header sized to the scroll view's width and
 *  attaches it as a subview positioned just above the scroll view's
 *  content.
 *
 *  @param scrollView The scroll view to attach to (a `UITableView`,
 *  `UICollectionView`, `AQGridView`, or any other `UIScrollView`
 *  subclass).
 *
 *  @return An initialized pull-to-refresh view, already added to
 *  `scrollView`.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

/**
 *  Call from the owner's `-scrollViewDidScroll:`. Tracks how far the user
 *  has pulled while dragging and switches between the "pull"/"release"
 *  states accordingly.
 */
- (void)scrollViewDidScroll;

/**
 *  Call from the owner's `-scrollViewDidEndDragging:willDecelerate:`. If
 *  the pull had crossed the release threshold, transitions to the loading
 *  state (holding the scroll view's top inset open) and notifies the
 *  delegate.
 */
- (void)scrollViewDidEndDragging;

/**
 *  Call once the fetch triggered by `-pullToRefreshViewDidTriggerRefresh:`
 *  completes (success or failure), to collapse the header back out of
 *  view. Does nothing if not currently loading.
 */
- (void)finishLoading;

@end
