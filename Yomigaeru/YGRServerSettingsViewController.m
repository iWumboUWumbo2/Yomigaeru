//
//  YGRServerSettingsViewController.m
//  Yomigaeru
//

#import "YGRServerSettingsViewController.h"
#import "YGRSettingsManager.h"
#import "YGRServerBaseURLViewController.h"

@interface YGRServerSettingsViewController ()

@property (nonatomic, strong) NSArray * serverSettings;
@property (nonatomic, strong) NSDictionary * serverSettingsViewControllers;

@end

@implementation YGRServerSettingsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.serverSettings = @[ @"Base URL" ];
        self.serverSettingsViewControllers = @{
            @"Base URL" : [YGRServerBaseURLViewController class]
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Server";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.serverSettings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
        
    NSString *rowTitle = [self.serverSettings objectAtIndex:indexPath.row];
    if ([rowTitle isEqualToString:@"Base URL"])
    {
        cell.textLabel.text = @"Base URL";
        cell.detailTextLabel.text = [[YGRSettingsManager sharedInstance] serverBaseURL].absoluteString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSString *rowTitle = [self.serverSettings objectAtIndex:indexPath.row];
    if ([rowTitle isEqualToString:@"Base URL"])
    {
        YGRServerBaseURLViewController *serverBaseURLViewController = [[YGRServerBaseURLViewController alloc] init];
        [self.navigationController pushViewController:serverBaseURLViewController animated:YES];
    }
}

@end
