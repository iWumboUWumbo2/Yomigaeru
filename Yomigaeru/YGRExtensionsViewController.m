//
//  YGRExtensionsViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/13.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRExtensionsViewController.h"

#import "YGRExtension.h"
#import "YGRExtensionService.h"

#import "YGRExtensionInfoViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

static NSString *const kExtensionUpdatesPendingKey = @"Updates pending";
static NSString *const kExtensionInstalledKey = @"Installed";

@interface YGRExtensionsViewController ()

@property (nonatomic, strong) YGRExtensionService *extensionService;

@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableDictionary *extensionsByLanguage;

@end

@implementation YGRExtensionsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        // Custom initialization
        _extensionService = [[YGRExtensionService alloc] init];
        _languages = [NSMutableArray array];
        _extensionsByLanguage = [NSMutableDictionary dictionary];
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
    [self fetchExtensions];
}

- (void)fetchExtensions
{
    self.languages = [NSMutableArray array];
    self.extensionsByLanguage = [NSMutableDictionary dictionary];

    __weak typeof(self) weakSelf = self;
    [self.extensionService fetchAllExtensionsWithCompletion:^(NSArray *extensions, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.refreshDelegate childDidFinishRefreshing];

        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                    initWithTitle:@"Error"
                          message:@"Failed to fetch extensions"
                         delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
                [alert show];
            });
            return;
        }

        // Temporary storage for updates and installed extensions
        NSMutableArray *updatesPending = [NSMutableArray array];
        NSMutableArray *installed = [NSMutableArray array];

        for (YGRExtension *extension in extensions)
        {
            if (extension.hasUpdate)
            {
                [updatesPending addObject:extension];
            }
            else if (extension.installed)
            {
                [installed addObject:extension];
            }
            else
            {
                NSMutableArray *arrayForLang =
                    [strongSelf.extensionsByLanguage objectForKey:extension.lang];
                if (!arrayForLang)
                {
                    arrayForLang = [NSMutableArray array];
                    [strongSelf.extensionsByLanguage setObject:arrayForLang forKey:extension.lang];
                    [strongSelf.languages addObject:extension.lang];
                }
                [arrayForLang addObject:extension];
            }
        }

        // Add "Updates pending" first if not empty
        if (updatesPending.count > 0)
        {
            [strongSelf.extensionsByLanguage setObject:updatesPending
                                                forKey:kExtensionUpdatesPendingKey];
            [strongSelf.languages insertObject:kExtensionUpdatesPendingKey atIndex:0];
        }

        // Add "Installed" second if not empty
        if (installed.count > 0)
        {
            [strongSelf.extensionsByLanguage setObject:installed forKey:kExtensionInstalledKey];
            NSUInteger insertIndex = (updatesPending.count > 0) ? 1 : 0;
            [strongSelf.languages insertObject:kExtensionInstalledKey atIndex:insertIndex];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
            [strongSelf.tableView layoutIfNeeded];
        });
    }];
}

- (void)refresh
{
    [self fetchExtensions];
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
    if (!arrayForLang)
    {
        return 0;
    }

    return arrayForLang.count;
}

- (YGRExtension *)extensionForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionLanguage = [self.languages objectAtIndex:indexPath.section];
    NSMutableArray *arrayForLang = [self.extensionsByLanguage objectForKey:sectionLanguage];
    if (!arrayForLang)
    {
        return nil;
    }

    return [arrayForLang objectAtIndex:indexPath.row];
}

- (MGSwipeButton *)swipeButtonWithTitle:(NSString *)title
                                  color:(UIColor *)color
                                 action:(dispatch_block_t)action
{
    return [MGSwipeButton buttonWithTitle:title
                          backgroundColor:color
                                 callback:^BOOL(MGSwipeTableCell *sender) {
                                     action();
                                     return YES;
                                 }];
}

- (void)handleExtensionResultWithSuccess:(BOOL)success error:(NSError *)error
{
    if (error || !success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"Error"
                      message:@"Extension operation failed"
                     delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
            [alert show];
        });
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchExtensions];
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"SwipeCell";

    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }

    YGRExtension *extension = [self extensionForRowAtIndexPath:indexPath];
    if (!extension)
    {
        return cell;
    }

    cell.textLabel.text = extension.name;
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSString *sectionLanguage = self.languages[indexPath.section];
    NSString *packageName = extension.pkgName; // capture immutable value

    __weak typeof(self) weakSelf = self;

    MGSwipeButton *swipeButton = nil;

    if ([sectionLanguage isEqualToString:kExtensionUpdatesPendingKey])
    {

        swipeButton = [self
            swipeButtonWithTitle:@"Update"
                           color:[UIColor brownColor]
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              if (!strongSelf)
                                  return;

                              [strongSelf.extensionService
                                  updateExtensionWithPackageName:packageName
                                                      completion:^(BOOL success, NSError *error) {
                                                          [strongSelf
                                                              handleExtensionResultWithSuccess:
                                                                  success
                                                                                         error:
                                                                                             error];
                                                      }];
                          }];
    }
    else if ([sectionLanguage isEqualToString:kExtensionInstalledKey])
    {

        swipeButton = [self
            swipeButtonWithTitle:@"Remove"
                           color:[UIColor redColor]
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              if (!strongSelf)
                                  return;

                              [strongSelf.extensionService
                                  uninstallExtensionWithPackageName:packageName
                                                         completion:^(BOOL success,
                                                                      NSError *error) {
                                                             [strongSelf
                                                                 handleExtensionResultWithSuccess:
                                                                     success
                                                                                            error:
                                                                                                error];
                                                         }];
                          }];
    }
    else
    {

        swipeButton = [self
            swipeButtonWithTitle:@"Add"
                           color:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0]
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              if (!strongSelf)
                                  return;

                              [strongSelf.extensionService
                                  installExtensionWithPackageName:packageName
                                                       completion:^(BOOL success, NSError *error) {
                                                           [strongSelf
                                                               handleExtensionResultWithSuccess:
                                                                   success
                                                                                          error:
                                                                                              error];
                                                       }];
                          }];
    }

    cell.rightButtons = @[ swipeButton ];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = YES;

    [cell.imageView setImageWithURL:extension.iconUrl
                   placeholderImage:[UIImage imageNamed:@"placeholder"]];

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
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath
*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new
row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
toIndexPath:(NSIndexPath *)toIndexPath
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

    YGRExtensionInfoViewController *extensionInfoViewController =
        [[YGRExtensionInfoViewController alloc] init];
    extensionInfoViewController.extension = [self extensionForRowAtIndexPath:indexPath];
    extensionInfoViewController.thumbnailImage = cell.imageView.image;

    [self.navigationController pushViewController:extensionInfoViewController animated:YES];
}

@end
