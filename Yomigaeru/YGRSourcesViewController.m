//
//  YGRSourcesViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourcesViewController.h"

#import "YGRSourceService.h"
#import "YGRSource.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface YGRSourcesViewController ()

@property (nonatomic, strong) YGRSourceService *sourceService;

@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableDictionary *sourcesByLanguage;

@end

@implementation YGRSourcesViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        self.sourceService = [[YGRSourceService alloc] init];
        self.languages = [NSMutableArray array];
        self.sourcesByLanguage = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        for (YGRSource *source in sources) {
            NSMutableArray *arrayForLang = [strongSelf.sourcesByLanguage objectForKey:source.lang];
            if (!arrayForLang) {
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
    // Return the number of sections.
    return !self.languages ? 1 : self.languages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionLanguage = [self.languages objectAtIndex:section];
    
    NSMutableArray *arrayForLang = [self.sourcesByLanguage objectForKey:sectionLanguage];
    if (!arrayForLang) {
        return 0;
    }
    
    return arrayForLang.count;
}

- (YGRSource *)sourceForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionLanguage = [self.languages objectAtIndex:indexPath.section];
    NSMutableArray *arrayForLang = [self.sourcesByLanguage objectForKey:sectionLanguage];
    if (!arrayForLang) {
        return nil;
    }
    
    return [arrayForLang objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    if (!source) {
        return cell;
    }
    cell.textLabel.text = source.displayName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.imageView setImageWithURL:source.iconUrl placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < 0 || section >= self.languages.count)
    {
        return @"Error";
    }
    
    return [self.languages objectAtIndex:section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
