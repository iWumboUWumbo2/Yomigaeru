//
//  YGRMangaViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/12/18.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRMangaViewController.h"

#import "YGRChapter.h"
#import "YGRChapterViewController.h"
#import "YGRMangaService.h"

@interface YGRMangaViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) NSArray *chapters;

@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@end

@implementation YGRMangaViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        // Custom initialization
        _mangaService = [[YGRMangaService alloc] init];
        _chapters = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.manga.title;

    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect bounds = self.tableView.bounds;
    self.loadingSpinner.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    [self.tableView addSubview:self.loadingSpinner];
}

- (void)fetchChapters
{
    [self.loadingSpinner startAnimating];

    __weak typeof(self) weakSelf = self;
    [self.mangaService fetchChaptersWithMangaId:self.manga.id_
                                     completion:^(NSArray *chapters, NSError *error) {
                                         __strong typeof(weakSelf) strongSelf = weakSelf;

                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [strongSelf.loadingSpinner stopAnimating];
                                         });

                                         if (error)
                                         {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 UIAlertView *alert = [[UIAlertView alloc]
                                                         initWithTitle:@"Error"
                                                               message:@"Failed to load chapters"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                                                 [alert show];
                                             });
                                             return;
                                         }

                                         strongSelf.chapters = chapters;

                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [strongSelf.tableView reloadData];
                                         });
                                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchChapters];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.chapters == nil ? 0 : self.chapters.count;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    YGRChapter *selectedChapter = [self.chapters objectAtIndex:indexPath.row];
    cell.textLabel.text = selectedChapter.name;

    return cell;
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
    YGRChapterViewController *chapterViewController = [[YGRChapterViewController alloc]
        initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                        options:nil];

    chapterViewController.manga = self.manga;

    YGRChapter *chapter = (YGRChapter *) self.chapters[indexPath.row];
    chapterViewController.chapterNumber = chapter.chapterNumber;
    chapterViewController.chapterIndex = chapter.index;
    chapterViewController.chapterCount = chapter.chapterCount;

    chapterViewController.refreshDelegate = self;

    // Pass the selected object to the new view controller.
    // Wrap in a navigation controller if you want a back button
    UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:chapterViewController];

    // Present modally (fullscreen)
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)childDidFinishRefreshing
{
    [self fetchChapters];
}

@end
