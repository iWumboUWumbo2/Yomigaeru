//
//  YGRReaderSettingsViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/30.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRReaderSettingsViewController.h"
#import "YGRStepperCell.h"
#import "YGRSwitchCell.h"

#import "YGRSettingsManager.h"

@implementation YGRReaderSettingsViewController

#pragma mark - Init

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - View Lifecycle

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

typedef NS_ENUM(NSInteger, YGRReaderSettingsSection) {
    YGRReaderSettingsSectionNextPrefetch,
    YGRReaderSettingsSectionPreviousPrefetch,
    YGRReaderSettingsSectionScrollDirection,
    YGRReaderSettingsSectionPaging,
    YGRReaderSettingsSectionCount
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return YGRReaderSettingsSectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case YGRReaderSettingsSectionNextPrefetch:
            return @"Number of next pages to preload";

        case YGRReaderSettingsSectionPreviousPrefetch:
            return @"Number of previous pages to preload";

        case YGRReaderSettingsSectionScrollDirection:
            return @"Scroll Direction";

        case YGRReaderSettingsSectionPaging:
            return @"Paging";

        default:
            break;
    }

    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case YGRReaderSettingsSectionNextPrefetch:
        case YGRReaderSettingsSectionPreviousPrefetch:
            return [self stepperCellForTableView:tableView atIndexPath:indexPath];

        case YGRReaderSettingsSectionScrollDirection:
        case YGRReaderSettingsSectionPaging:
            return [self switchCellForTableView:tableView atIndexPath:indexPath];

        default:
            return nil;
    }
}

- (UITableViewCell *)stepperCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StepperCell";
    YGRStepperCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[YGRStepperCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    NSInteger value = -1;

    switch (indexPath.section) {
        case YGRReaderSettingsSectionNextPrefetch:
            value = [[YGRSettingsManager sharedInstance] nextPrefetchCount];
            cell.minimumValue = 2;
            cell.tag = YGRStepperTagNextPrefetch;
            break;

        case YGRReaderSettingsSectionPreviousPrefetch:
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

- (UITableViewCell *)switchCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SwitchCell";
    YGRSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[YGRSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    switch (indexPath.section) {
        case YGRReaderSettingsSectionScrollDirection:
            cell.textLabel.text = @"Vertical Scrolling";
            cell.tag = YGRSwitchTagVerticalScrolling;
            cell.on = [[YGRSettingsManager sharedInstance] readingDirection] == YGRReadingDirectionVertical;
            break;

        case YGRReaderSettingsSectionPaging:
            cell.textLabel.text = @"Paging Enabled";
            cell.tag = YGRSwitchTagPagingEnabled;
            cell.on = [[YGRSettingsManager sharedInstance] pagingEnabled];
            break;

        default:
            break;
    }

    return cell;
}

@end
