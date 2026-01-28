//
//  YGRBrowseSearchBarDelegateProxy.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRBrowseSearchBarDelegateProxy.h"

@implementation YGRBrowseSearchBarDelegateProxy

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.stateHandler respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    {
        [self.stateHandler searchBarCancelButtonClicked:searchBar];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([self.searchHandler respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
    {
        [self.searchHandler searchBarTextDidBeginEditing:searchBar];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([self.searchHandler respondsToSelector:@selector(searchBarTextDidEndEditing:)])
    {
        [self.searchHandler searchBarTextDidEndEditing:searchBar];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchHandler respondsToSelector:@selector(searchBarSearchButtonClicked:)])
    {
        [self.searchHandler searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.searchHandler respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.searchHandler searchBar:searchBar textDidChange:searchText];
    }
}

@end
