//
//  YGRExtensionInfoViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/14.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRExtensionInfoViewController.h"

@interface YGRExtensionInfoViewController ()

@end

@implementation YGRExtensionInfoViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Extensions";
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = self.thumbnailImage;
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.extension.name;
            break;
        case 1:
            cell.textLabel.text = @"Package Name";
            cell.detailTextLabel.text = self.extension.pkgName;
            break;
        case 2:
            cell.textLabel.text = @"Version";
            cell.detailTextLabel.text = self.extension.versionName;
            break;
        case 3:
            cell.textLabel.text = @"Language";
            cell.detailTextLabel.text = self.extension.lang;
            break;
    }
    
    return cell;
}

@end
