//
//  YGRMangaInfoViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/26.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRMangaInfoViewController.h"
#import "YGRMangaDescriptionViewController.h"

#import "YGRMangaService.h"
#import "YGRImageService.h"
#import "YGRMangaStatusUtility.h"

@interface YGRMangaInfoViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) YGRManga *manga;
@property (nonatomic, strong) UIImage *thumbnailImage;

@end

@implementation YGRMangaInfoViewController

#pragma mark - Init

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _mangaService = [[YGRMangaService alloc] init];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Info";
    
    self.tableView.allowsSelection = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchMangaInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Data Fetching

- (void)fetchMangaInfo
{
    __weak typeof(self) weakSelf = self;
    
    [self.mangaService fetchFullMangaWithId:self.mangaId
                                 completion:^(YGRManga *manga, NSError *error) {
                                     __strong typeof(weakSelf) strongSelf = weakSelf;
                                     if (!strongSelf)
                                         return;
                                     
                                     if (error || !manga)
                                         return;
                                     
                                     strongSelf.manga = manga;
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         strongSelf.title = manga.title;
                                         [strongSelf.tableView reloadData];
                                     });
                                     
                                     [strongSelf fetchThumbnail];
                                 }];
}

- (void)fetchThumbnail
{
    __weak typeof(self) weakSelf = self;
    
    [[YGRImageService sharedService]
     fetchThumbnailWithMangaId:self.mangaId
     completion:^(UIImage *image, NSError *error) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         if (!strongSelf)
             return;
         
         if (!error && image)
         {
             strongSelf.thumbnailImage = image;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [strongSelf.tableView reloadRowsAtIndexPaths:@[
                                                                [NSIndexPath indexPathForRow:0 inSection:0]
                                                                ] withRowAnimation:UITableViewRowAnimationFade];
             });
         }
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 4;
    
    if (section == 1)
    {
        NSArray *genres = [self.manga.genres isKindOfClass:[NSArray class]]
        ? self.manga.genres
        : nil;
        
        return genres.count > 0 ? genres.count : 1;
    }
    
    if (section == 2)
        return 1;
    
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"Manga";
        case 1: return @"Genres";
        case 2: return @"Details";
        default: return nil;
    }
}


- (NSString *)safeString:(id)value
{
    if (!value || value == [NSNull null])
        return nil;
    
    if (![value isKindOfClass:[NSString class]])
        return nil;
    
    return value;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InfoCell";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Reset reused content
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *title  = [self safeString:self.manga.title];
    NSString *author = [self safeString:self.manga.author];
    NSString *artist = [self safeString:self.manga.artist];
    NSString *desc   = [self safeString:self.manga.description_];
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                cell.imageView.image = self.thumbnailImage;
                cell.textLabel.text = @"Name";
                cell.detailTextLabel.text = title ?: @"—";
                break;
                
            case 1:
                cell.textLabel.text = @"Author";
                cell.detailTextLabel.text = author ?: @"—";
                break;
                
            case 2:
                cell.textLabel.text = @"Artist";
                cell.detailTextLabel.text = artist ?: @"—";
                break;
                
            case 3:
                cell.textLabel.text = @"Status";
                cell.detailTextLabel.text =
                [YGRMangaStatusUtility stringFromMangaStatus:self.manga.status];
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        NSArray *genres = [self.manga.genres isKindOfClass:[NSArray class]]
        ? self.manga.genres
        : nil;
        
        if (genres.count == 0)
        {
            cell.textLabel.text = @"—";
        }
        else
        {
            id value = genres[indexPath.row];
            cell.textLabel.text =
            [value isKindOfClass:[NSString class]] ? value : @"—";
        }
    }
    else if (indexPath.section == 2)
    {
        cell.textLabel.text = @"Description";
        cell.detailTextLabel.text = desc.length ? @"View" : @"—";
        cell.accessoryType = desc.length
        ? UITableViewCellAccessoryDisclosureIndicator
        : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        NSString *desc = [self safeString:self.manga.description_];
        if (!desc.length)
            return;
        
        YGRMangaDescriptionViewController *vc = [[YGRMangaDescriptionViewController alloc] init];
        
        vc.mangaTitle = self.manga.title;
        vc.mangaDescription = desc;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
