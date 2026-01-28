//
//  YGRMangaDescriptionViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/28.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRMangaDescriptionViewController.h"

@implementation YGRMangaDescriptionViewController

#pragma mark - Init

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.mangaTitle ?: @"Description";
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? @"Description" : nil;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    // Adds the nice bottom spacing Apple uses
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DescriptionCell";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    NSString *desc = self.mangaDescription;
    if (![desc isKindOfClass:[NSString class]] || desc.length == 0)
        desc = @"—";
    
    cell.textLabel.text = desc;
    
    return cell;
}

#pragma mark - Dynamic height

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat padding = 20.0f; // matches grouped table insets
    
    NSString *desc = self.mangaDescription;
    if (![desc isKindOfClass:[NSString class]] || desc.length == 0)
        desc = @"—";
    
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    
    CGSize constraint =
    CGSizeMake(tableView.bounds.size.width - padding * 2,
               CGFLOAT_MAX);
    
    CGSize size =
    [desc sizeWithFont:font
     constrainedToSize:constraint
         lineBreakMode:NSLineBreakByWordWrapping];
    
    // Top + bottom padding
    return size.height * 1.5 + 24.0f;
}

@end