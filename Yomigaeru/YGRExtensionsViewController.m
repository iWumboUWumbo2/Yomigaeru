//
//  YGRExtensionsViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRExtensionsViewController.h"

#import "YGRExtensionService.h"
#import "YGRExtension.h"

#import "YGRExtensionInfoViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface YGRExtensionsViewController ()

@property (nonatomic, strong) YGRExtensionService *extensionService;

@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableDictionary *extensionsByLanguage;

@end

@implementation YGRExtensionsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        self.extensionService = [[YGRExtensionService alloc] init];
        self.languages = [NSMutableArray array];
        self.extensionsByLanguage = [NSMutableDictionary dictionary];
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
    
    [self fetchExtensions];
}

- (void)fetchExtensions
{
    static NSString *const kExtensionUpdatesPendingKey = @"Updates pending";
    static NSString *const kExtensionInstalledKey = @"Installed";
    
    self.languages = [NSMutableArray arrayWithObjects:kExtensionUpdatesPendingKey, kExtensionInstalledKey, nil];
    self.extensionsByLanguage = [NSMutableDictionary dictionaryWithDictionary:@{
                                                 kExtensionUpdatesPendingKey : [NSMutableArray array],
                                                      kExtensionInstalledKey : [NSMutableArray array]
                                 }];
    
    __weak typeof(self) weakSelf = self;
    [self.extensionService fetchAllExtensionsWithCompletion:^(NSArray *extensions, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        for (YGRExtension *extension in extensions) {
            if (extension.hasUpdate)
            {
                NSMutableArray *updatesPending = [strongSelf.extensionsByLanguage objectForKey:kExtensionUpdatesPendingKey];
                [updatesPending addObject:extension];
                continue;
            }
            
            if (extension.installed)
            {
                NSMutableArray *installed = [strongSelf.extensionsByLanguage objectForKey:kExtensionInstalledKey];
                [installed addObject:extension];
                continue;
            }
            
            NSMutableArray *arrayForLang = [strongSelf.extensionsByLanguage objectForKey:extension.lang];
            if (!arrayForLang) {
                arrayForLang = [NSMutableArray array];
                [strongSelf.extensionsByLanguage setObject:arrayForLang forKey:extension.lang];
                
                [strongSelf.languages addObject:extension.lang];
            }
            [arrayForLang addObject:extension];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
            [strongSelf.tableView layoutIfNeeded];
        });
    }];
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
    
    NSMutableArray *arrayForLang = [self.extensionsByLanguage objectForKey:sectionLanguage];
    if (!arrayForLang) {
        return 0;
    }
    
    return arrayForLang.count;
}

- (YGRExtension *)extensionForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionLanguage = [self.languages objectAtIndex:indexPath.section];
    NSMutableArray *arrayForLang = [self.extensionsByLanguage objectForKey:sectionLanguage];
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
    YGRExtension *extension = [self extensionForRowAtIndexPath:indexPath];
    if (!extension) {
        return cell;
    }
    cell.textLabel.text = extension.name;
    [cell.imageView setImageWithURL:extension.iconUrl placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    YGRExtensionInfoViewController *extensionInfoViewController = [[YGRExtensionInfoViewController alloc] init];
    extensionInfoViewController.extension = [self extensionForRowAtIndexPath:indexPath];
    extensionInfoViewController.thumbnailImage = cell.imageView.image;
    
    [self.parentViewController.navigationController pushViewController:extensionInfoViewController animated:YES];
}

@end
