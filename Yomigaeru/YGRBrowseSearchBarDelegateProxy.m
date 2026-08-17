//
//  YGRBrowseSearchBarDelegateProxy.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRBrowseSearchBarDelegateProxy.h"

@implementation YGRBrowseSearchBarDelegateProxy

#pragma mark - UISearchBarDelegate

/**
 *  Forwards the cancel-button-clicked event to `stateHandler`, if it
 *  implements this method.
 *
 *  @param searchBar The search bar whose cancel button was clicked.
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.stateHandler respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    {
        [self.stateHandler searchBarCancelButtonClicked:searchBar];
    }
}

/**
 *  Forwards the begin-editing event to `searchHandler`, if it implements
 *  this method.
 *
 *  @param searchBar The search bar that began editing.
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([self.searchHandler respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
    {
        [self.searchHandler searchBarTextDidBeginEditing:searchBar];
    }
}

/**
 *  Forwards the end-editing event to `searchHandler`, if it implements this
 *  method.
 *
 *  @param searchBar The search bar that ended editing.
 */
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([self.searchHandler respondsToSelector:@selector(searchBarTextDidEndEditing:)])
    {
        [self.searchHandler searchBarTextDidEndEditing:searchBar];
    }
}

/**
 *  Forwards the search-button-clicked event to `searchHandler`, if it
 *  implements this method.
 *
 *  @param searchBar The search bar whose search button was clicked.
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchHandler respondsToSelector:@selector(searchBarSearchButtonClicked:)])
    {
        [self.searchHandler searchBarSearchButtonClicked:searchBar];
    }
}

/**
 *  Forwards text-changed events to `searchHandler`, if it implements this
 *  method.
 *
 *  @param searchBar The search bar whose text changed.
 *  @param searchText The search bar's current text.
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.searchHandler respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.searchHandler searchBar:searchBar textDidChange:searchText];
    }
}

@end
