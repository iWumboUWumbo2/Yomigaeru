//
//  YGRReaderSettingsViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/30.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRReaderSettingsViewController.h"
#import "YGRStepperCell.h"

#import "YGRSettingsManager.h"

@interface YGRReaderSettingsViewController ()

@property (nonatomic, strong) NSArray *readerSettings;
@property (nonatomic, strong) NSDictionary *readerSettingsViewControllers;

@end

@implementation YGRReaderSettingsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _readerSettings = @[ @"Prefetch" ];
        _readerSettingsViewControllers = @{@"Prefetch" : [NSNull new]};
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Reader";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Number of next pages to preload";
            
        case 1:
            return @"Number of previous pages to preload";
            
        default:
            break;
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.readerSettings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StepperCell";
    YGRStepperCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[YGRStepperCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSInteger value = -1;
    
    switch (indexPath.section) {
        case 0:
            value = [[YGRSettingsManager sharedInstance] nextPrefetchCount];
            cell.minimumValue = 2;
            cell.tag = YGRStepperTagNextPrefetch;
            break;
        
        case 1:
            value = [[YGRSettingsManager sharedInstance] previousPrefetchCount];
            cell.minimumValue = 1;
            cell.tag = YGRStepperTagPreviousPrefetch;
            break;
            
        default:
            break;
    }
    
    cell.maximumValue = 10;
    cell.value = value;
        
    return cell;
}

@end
