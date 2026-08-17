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

#pragma mark - Init

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle

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

#pragma mark - Settings Persistence

/**
 *  Validates and saves the text field's contents as the server base URL,
 *  showing an alert if the text isn't a URL with both a scheme and a host.
 *
 *  @param textField The text field whose text should be saved.
 */
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
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Invalid URL"
                  message:@"Please enter a valid URL with scheme and host"
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UITextFieldDelegate

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

#pragma mark - View Lifecycle

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
    cell.textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    cell.textField.delegate = self;
    cell.textField.returnKeyType = UIReturnKeyDone;
    return cell;
}

@end
