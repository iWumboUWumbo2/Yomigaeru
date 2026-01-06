//
//  YGRLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRLibraryViewController.h"
#import "YGRMangaViewController.h"

#import "YGRCategoryService.h"
#import "YGRMangaService.h"
#import "YGRManga.h"

@interface YGRLibraryViewController ()

@property (nonatomic, strong) YGRCategoryService *categoryService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangas;
@property (nonatomic, strong) NSMutableArray *mangaThumbnails;

@end

@implementation YGRLibraryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.categoryService = [[YGRCategoryService alloc] init];
        self.mangaService = [[YGRMangaService alloc] init];
        
        self.mangas = nil;
        self.mangaThumbnails = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    __weak typeof(self) weakSelf = self;
    
    [self.categoryService fetchLibraryWithCompletion:^(NSArray *mangas, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        
        strongSelf.mangas = [NSMutableArray arrayWithArray:mangas];
        
        strongSelf.mangaThumbnails = [NSMutableArray arrayWithCapacity:strongSelf.mangas.count];
        for (NSUInteger i = 0; i < mangas.count; i++) {
            [strongSelf.mangaThumbnails addObject:[NSNull null]];
        }
        
        for (NSUInteger i = 0; i < mangas.count; i++) {
            YGRManga *manga = [mangas objectAtIndex:i];
            
            [strongSelf.mangaService fetchThumbnailWithMangaId:manga.id_ completion:^(UIImage *thumbnailImage, NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                    return;
                }
                
                if (!thumbnailImage) {
                    NSLog(@"Failed to load image");
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.mangaThumbnails replaceObjectAtIndex:i withObject:thumbnailImage];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    if ([strongSelf.tableView.indexPathsForVisibleRows containsObject:indexPath])
                    {
                        [strongSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
                
                
            }];
        }
        
        [strongSelf.tableView reloadData];
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
	return YES;
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
    return self.mangas == nil ? 0 : self.mangas.count;
}

/*
- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    return 240;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    YGRManga *manga = [self.mangas objectAtIndex:indexPath.row];
    cell.textLabel.text = manga.title;
    
    id thumbnail = [self.mangaThumbnails objectAtIndex:indexPath.row];
    if ([thumbnail isKindOfClass:[UIImage class]]) {
        cell.imageView.image = thumbnail;
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YGRManga *selectedManga = [self.mangas objectAtIndex:indexPath.row];

        __weak typeof(self) weakSelf = self;
        
        [[self mangaService] deleteFromLibraryWithMangaId:selectedManga.id_ completion:^(BOOL success, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            
            if (success)
            {
                [strongSelf.mangas removeObjectAtIndex:indexPath.row];
                // Delete the row from the data source
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.    
    YGRMangaViewController *mangaViewController = [[YGRMangaViewController alloc] initWithStyle:UITableViewStylePlain];
    
    YGRManga *selectedManga = [self.mangas objectAtIndex:indexPath.row];
    mangaViewController.mangaId = selectedManga.id_;
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:mangaViewController animated:YES];
     
}

@end
