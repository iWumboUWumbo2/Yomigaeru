//
//  YGRBrowseSearchBarDelegateProxy.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Fans a single UISearchBarDelegate out to two separate delegates: one that
 *  reacts to search-bar chrome/state changes and one that reacts to search
 *  text/query changes. Lets a view controller keep those two concerns in
 *  separate objects while presenting only one delegate to the search bar.
 */
@interface YGRBrowseSearchBarDelegateProxy : NSObject <UISearchBarDelegate>

#pragma mark - Handlers

/** Receives the cancel-button-clicked callback. */
@property (nonatomic, weak) id<UISearchBarDelegate> stateHandler;
/** Receives the text-changed, editing-began/ended, and search-button callbacks. */
@property (nonatomic, weak) id<UISearchBarDelegate> searchHandler;

@end
