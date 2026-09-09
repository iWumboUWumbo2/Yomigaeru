//
//  YGRSourcesViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourcesViewController.h"

#import "YGRPullToRefreshView.h"
#import "YGRSourceLibraryViewController.h"
#import "YGRSourceService.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface YGRSourcesViewController () <YGRPullToRefreshDelegate>

@property (nonatomic, strong) YGRSourceService *sourceService;

@property (nonatomic, strong) YGRPullToRefreshView *pullToRefreshView;

@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableDictionary *sourcesByLanguage;

@property (nonatomic, strong) NSMutableArray *searchLanguages;
@property (nonatomic, strong) NSMutableDictionary *searchSourcesByLanguage;

@property (nonatomic, assign) BOOL isSearching;

@end

@implementation YGRSourcesViewController

#pragma mark - Initialization

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        // Custom initialization
        _sourceService = [[YGRSourceService alloc] init];
        _languages = [NSMutableArray array];
        _sourcesByLanguage = [NSMutableDictionary dictionary];
        
        _searchLanguages = [NSMutableArray array];
        _searchSourcesByLanguage = [NSMutableDictionary dictionary];
        
        _isSearching = NO;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pullToRefreshView = [[YGRPullToRefreshView alloc] initWithScrollView:self.tableView];
    self.pullToRefreshView.delegate = self;
}

#pragma mark - UIScrollViewDelegate (via UITableViewDelegate)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullToRefreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullToRefreshView scrollViewDidEndDragging];
}

#pragma mark - YGRPullToRefreshDelegate

- (void)pullToRefreshViewDidTriggerRefresh:(YGRPullToRefreshView *)pullToRefreshView
{
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchSources];
}

#pragma mark - Data Fetching

/**
 *  Fetches every source from the server and buckets them by language into
 *  `languages`/`sourcesByLanguage`, then reloads the table. Collapses the
 *  pull-to-refresh header when the fetch completes, and shows an alert on
 *  failure.
 */
- (void)fetchSources
{
    [self.languages removeAllObjects];
    [self.sourcesByLanguage removeAllObjects];

    __weak typeof(self) weakSelf = self;
    [self.sourceService fetchAllSourcesWithCompletion:^(NSArray *sources, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [strongSelf.pullToRefreshView finishLoading];

        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                    initWithTitle:@"Error"
                          message:@"Failed to fetch sources"
                         delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
                [alert show];
            });
            return;
        }

        for (YGRSource *source in sources)
        {
            NSMutableArray *arrayForLang = strongSelf.sourcesByLanguage[source.lang];
            if (!arrayForLang)
            {
                arrayForLang = [NSMutableArray array];
                strongSelf.sourcesByLanguage[source.lang] = arrayForLang;

                [strongSelf.languages addObject:source.lang];
            }
            [arrayForLang addObject:source];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
            [strongSelf.tableView layoutIfNeeded];
        });
    }];
}

#pragma mark - YGRRefreshable

/**
 *  Re-fetches the source list. Called by the `YGRPullToRefreshDelegate`
 *  callback on user pull, and available to any other caller via the
 *  `YGRRefreshable` protocol.
 */
- (void)refresh
{
    [self fetchSources];
}

#pragma mark - Lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *languageArray = (self.isSearching) ? self.searchLanguages : self.languages;
    return !languageArray ? 1 : languageArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *languageArray = (self.isSearching) ? self.searchLanguages : self.languages;
    NSDictionary *sourcesByLanguageDictionary = (self.isSearching) ? self.searchSourcesByLanguage : self.sourcesByLanguage;
    
    NSString *sectionLanguage = languageArray[section];

    NSMutableArray *arrayForLang = sourcesByLanguageDictionary[sectionLanguage];
    if (!arrayForLang)
    {
        return 0;
    }

    return arrayForLang.count;
}

/**
 *  Looks up the source backing a given row, taking into account whether the
 *  table is currently showing the search results or the full source list.
 *
 *  @param indexPath The index path of the row.
 *
 *  @return The matching source, or `nil` if the section/row don't resolve
 *  to one (e.g. a stale index path during a search update).
 */
- (YGRSource *)sourceForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *languageArray = (self.isSearching) ? self.searchLanguages : self.languages;
    NSDictionary *sourcesByLanguageDictionary = (self.isSearching) ? self.searchSourcesByLanguage : self.sourcesByLanguage;
    
    NSString *sectionLanguage = languageArray[indexPath.section];
    NSMutableArray *arrayForLang = sourcesByLanguageDictionary[sectionLanguage];
    if (!arrayForLang)
    {
        return nil;
    }

    return arrayForLang[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    YGRSource *source = [self sourceForRowAtIndexPath:indexPath];
    if (!source)
    {
        return cell;
    }
    cell.textLabel.text = source.displayName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.imageView setImageWithURL:source.iconUrl
                   placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *languageArray = (self.isSearching) ? self.searchLanguages : self.languages;
    
    if (section < 0 || section >= languageArray.count)
    {
        return @"Error";
    }

    return languageArray[section];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGRSourceLibraryViewController *sourceLibraryViewController =
        [[YGRSourceLibraryViewController alloc] init];

    sourceLibraryViewController.source = [self sourceForRowAtIndexPath:indexPath];

    [self.navigationController pushViewController:sourceLibraryViewController animated:YES];
}

#pragma mark - Search bar delegate

/**
 *  Rebuilds `searchLanguages`/`searchSourcesByLanguage` from `languages`/
 *  `sourcesByLanguage`, keeping only sources whose lowercased name has
 *  `searchTerm` as a prefix. An empty term copies the full, unfiltered list.
 *
 *  @param searchTerm The current search bar text.
 */
- (void)filterSourcesBySearchTerm:(NSString *)searchTerm
{
    if (searchTerm.length == 0) {
        self.searchLanguages = [self.languages mutableCopy];
        self.searchSourcesByLanguage = [self.sourcesByLanguage mutableCopy];
        return;
    }
    
    [self.searchLanguages removeAllObjects];
    [self.searchSourcesByLanguage removeAllObjects];
    
    NSString *term = [searchTerm lowercaseString];
    
    for (NSString *language in self.languages) {
        NSArray *sources = self.sourcesByLanguage[language];
        BOOL addedLanguage = NO;
        
        for (YGRSource *source in sources) {
            if ([source.lowerName hasPrefix:term]) {
                if (!addedLanguage) {
                    addedLanguage = YES;
                    [self.searchLanguages addObject:language];
                    self.searchSourcesByLanguage[language] = [NSMutableArray array];
                }
                
                [self.searchSourcesByLanguage[language] addObject:source];
            }
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.isSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.isSearching = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
    });
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterSourcesBySearchTerm:searchText];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterSourcesBySearchTerm:searchBar.text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
    });
    
    [searchBar resignFirstResponder];
}

@end
