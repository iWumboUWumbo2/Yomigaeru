//
//  YGRServerBaseURLViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/07.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRServerBaseURLViewController.h"
#import "YGRSettingsManager.h"
#import "YGRTextFieldCell.h"

@interface YGRServerBaseURLViewController () <UITextFieldDelegate>

@end

@implementation YGRServerBaseURLViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Get the text field from the table view cell
    YGRTextFieldCell *cell = (YGRTextFieldCell *) [self.tableView
        cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField becomeFirstResponder];
}

- (void)saveSettingsForTextField:(UITextField *)textField
{
    NSURL *url = [NSURL URLWithString:textField.text];
    if (url && url.scheme && url.host)
    {
        [[YGRSettingsManager sharedInstance] setServerBaseURL:url];
        NSLog(@"Saved URL: %@", url.absoluteString);
    }
    else
    {
        NSLog(@"Invalid URL: %@", textField.text);
    }
}

// Called when user taps Return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Save settings
    [self saveSettingsForTextField:textField];

    // Dismiss the keyboard
    [textField resignFirstResponder];

    return YES;
}

// Called when editing ends by other means (tapping elsewhere)
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self saveSettingsForTextField:textField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGRTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if (!cell)
    {
        cell = [[YGRTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"TextFieldCell"
                                           placeholder:@"http://localhost:4567/"];
    }
    cell.textField.text = [[YGRSettingsManager sharedInstance] serverBaseURL].absoluteString;
    cell.textField.textColor = [UIColor darkGrayColor];
    cell.textField.delegate = self;
    cell.textField.returnKeyType = UIReturnKeyDone;
    return cell;
}

@end
