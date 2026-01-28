//
//  YGRSourcesViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourcesViewController.h"

#import "YGRSourceLibraryViewController.h"
#import "YGRSourceService.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface YGRSourcesViewController ()

@property (nonatomic, strong) YGRSourceService *sourceService;

@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableDictionary *sourcesByLanguage;

@property (nonatomic, strong) NSMutableArray *searchLanguages;
@property (nonatomic, strong) NSMutableDictionary *searchSourcesByLanguage;

@property (nonatomic, assign) BOOL isSearching;

@end

@implementation YGRSourcesViewController

- (id)init
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view
    // controller. self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchSources];
}

- (void)fetchSources
{
    [self.languages removeAllObjects];
    [self.sourcesByLanguage removeAllObjects];

    __weak typeof(self) weakSelf = self;
    [self.sourceService fetchAllSourcesWithCompletion:^(NSArray *sources, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.refreshDelegate childDidFinishRefreshing];

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
            NSMutableArray *arrayForLang = [strongSelf.sourcesByLanguage objectForKey:source.lang];
            if (!arrayForLang)
            {
                arrayForLang = [NSMutableArray array];
                [strongSelf.sourcesByLanguage setObject:arrayForLang forKey:source.lang];

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

- (void)refresh
{
    [self fetchSources];
}

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
    
    NSString *sectionLanguage = [languageArray objectAtIndex:section];

    NSMutableArray *arrayForLang = [sourcesByLanguageDictionary objectForKey:sectionLanguage];
    if (!arrayForLang)
    {
        return 0;
    }

    return arrayForLang.count;
}

- (YGRSource *)sourceForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *languageArray = (self.isSearching) ? self.searchLanguages : self.languages;
    NSDictionary *sourcesByLanguageDictionary = (self.isSearching) ? self.searchSourcesByLanguage : self.sourcesByLanguage;
    
    NSString *sectionLanguage = [languageArray objectAtIndex:indexPath.section];
    NSMutableArray *arrayForLang = [sourcesByLanguageDictionary objectForKey:sectionLanguage];
    if (!arrayForLang)
    {
        return nil;
    }

    return [arrayForLang objectAtIndex:indexPath.row];
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

    return [languageArray objectAtIndex:section];
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
