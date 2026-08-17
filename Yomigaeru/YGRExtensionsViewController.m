//
//  YGRExtensionsViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRExtensionsViewController.h"

#import "YGRExtensionsViewModel.h"
#import "YGRExtension.h"
#import "YGRExtensionInfoViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface YGRExtensionsViewController () <UISearchBarDelegate>

@property (nonatomic, strong) YGRExtensionsViewModel *viewModel;

@end

@implementation YGRExtensionsViewController

#pragma mark - Init

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _viewModel = [[YGRExtensionsViewModel alloc] init];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refresh];
}

#pragma mark - YGRRefreshable

/**
 *  Re-fetches the extensions list via the view model and reloads the table
 *  view on completion.
 */
- (void)refresh
{
    __weak typeof(self) weakSelf = self;
    [self.viewModel refreshWithCompletion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.viewModel.sections[section];
}

/**
 *  Looks up the extension model backing the given index path via the view
 *  model.
 *
 *  @param indexPath The table view index path.
 *
 *  @return The extension at that index path.
 */
- (YGRExtension *)extensionForIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel extensionAtIndexPath:indexPath];
}

/**
 *  Configures a swipeable cell for the extension at the given index path.
 *  The trailing swipe action's title and behavior (Update, Remove, or Add)
 *  depend on which section the row belongs to.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SwipeCell";
    
    MGSwipeTableCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MGSwipeTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    YGRExtension *extension = [self extensionForIndexPath:indexPath];
    NSString *section = self.viewModel.sections[indexPath.section];
    
    cell.textLabel.text = extension.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell.imageView setImageWithURL:extension.iconUrl
                   placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    __weak typeof(self) weakSelf = self;
    
    MGSwipeButton *button = nil;
    
    if ([section isEqualToString:kExtensionUpdatesPendingKey]) {
        button = [MGSwipeButton buttonWithTitle:@"Update"
                                backgroundColor:[UIColor brownColor]
                                       callback:^BOOL(MGSwipeTableCell *_) {
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           if (!strongSelf) return NO;
                                           [strongSelf.viewModel updateExtension:extension
                                                                      completion:^(NSError *error) {
                                                                          [strongSelf refresh];
                                                                      }];
                                           return YES;
                                       }];
    }
    else if ([section isEqualToString:kExtensionInstalledKey]) {
        button = [MGSwipeButton buttonWithTitle:@"Remove"
                                backgroundColor:[UIColor redColor]
                                       callback:^BOOL(MGSwipeTableCell *_) {
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           if (!strongSelf) return NO;
                                           [strongSelf.viewModel removeExtension:extension
                                                                      completion:^(NSError *error) {
                                                                          [strongSelf refresh];
                                                                      }];
                                           return YES;
                                       }];
    }
    else {
        button = [MGSwipeButton buttonWithTitle:@"Add"
                                backgroundColor:[UIColor colorWithRed:0.22
                                                                green:0.33
                                                                 blue:0.53
                                                                alpha:1.0]
                                       callback:^BOOL(MGSwipeTableCell *_) {
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           if (!strongSelf) return NO;
                                           [strongSelf.viewModel installExtension:extension
                                                                       completion:^(NSError *error) {
                                                                           [strongSelf refresh];
                                                                       }];
                                           return YES;
                                       }];
    }
    
    cell.rightButtons = @[ button ];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = YES;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    YGRExtensionInfoViewController *vc =
    [[YGRExtensionInfoViewController alloc] init];
    
    vc.extension = [self extensionForIndexPath:indexPath];
    vc.thumbnailImage = cell.imageView.image;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        [self.viewModel searchWithTerm:searchText];
    } else {
        [self.viewModel clearSearch];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
