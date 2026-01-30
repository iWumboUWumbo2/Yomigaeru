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
#import "YGRMangaInfoViewController.h"
#import "YGRMangaService.h"

@interface YGRMangaViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) NSArray *chapters;

@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIBarButtonItem *continueButton;

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
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    return self;
}

- (void)configureToolbar
{
    UIBarButtonItem *markReadButton = [[UIBarButtonItem alloc] initWithTitle:@"Read" style:UIBarButtonItemStylePlain target:self action:@selector(markSelectedChaptersRead)];
    
    UIBarButtonItem *flexibleSpace =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    
    UIBarButtonItem *markUnreadButton = [[UIBarButtonItem alloc] initWithTitle:@"Unread" style:UIBarButtonItemStylePlain target:self action:@selector(markSelectedChaptersUnread)];
    
    self.toolbarItems = @[ flexibleSpace,
                           markReadButton,
                           flexibleSpace,
                           markUnreadButton,
                           flexibleSpace ];
}

- (void)showAlertForChapter:(YGRChapter *)chapter
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:[NSString stringWithFormat:@"Failed to load Chapter %.1f",
                                   chapter.chapterNumber]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)markSelectedChaptersWithReadStatus:(BOOL)readStatus
{
    NSArray *selected = [self.tableView indexPathsForSelectedRows];
    
    if (selected == nil || selected.count == 0) return;
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();
    
    for (NSIndexPath *indexPath in selected)
    {
        YGRChapter *chapter = self.chapters[indexPath.row];
        
        if (chapter.read == readStatus) continue;
        
        dispatch_group_enter(group);
        
        [self.mangaService markReadStatusChapterWithMangaId:self.manga.id_
                                               chapterIndex:chapter.index
                                                 readStatus:readStatus
                                                 completion:^(BOOL success, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (success && !error)
                 {
                     chapter.read = readStatus;
                 }
                 else
                 {
                     [weakSelf showAlertForChapter:chapter];
                 }
                 dispatch_group_leave(group);
             });
         }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadRowsAtIndexPaths:selected
                                  withRowAnimation:UITableViewRowAnimationNone];
    });
    
    [self setEditing:NO animated:YES];
}


- (void)markSelectedChaptersRead
{
    [self markSelectedChaptersWithReadStatus:YES];
}


- (void)markSelectedChaptersUnread
{
    [self markSelectedChaptersWithReadStatus:NO];
}

- (void)continueReading
{
    // Navigation logic may go here. Create and push another view controller.
    YGRChapterViewController *chapterViewController = [[YGRChapterViewController alloc]
                                                       initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                       navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                       options:nil];
    
    chapterViewController.manga = self.manga;
    
    YGRChapter *chapter = self.manga.lastChapterRead;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.manga.title;
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton addTarget:self
                   action:@selector(showMangaInfo)
         forControlEvents:UIControlEventTouchUpInside];
    
    self.continueButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(continueReading)];
    self.continueButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItems = @[ [[UIBarButtonItem alloc] initWithCustomView:infoButton], self.continueButton ];

    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect bounds = self.tableView.bounds;
    self.loadingSpinner.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    [self.tableView addSubview:self.loadingSpinner];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.tableView addGestureRecognizer:longPress];
    
    [self configureToolbar];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    static UIColor *defaultTextLabelHighlightedTextColor = nil;
    static UIColor *defaultDetailTextLabelHighlightedTextColor = nil;
    
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        if (!defaultTextLabelHighlightedTextColor)
        {
            defaultTextLabelHighlightedTextColor = cell.textLabel.highlightedTextColor;
        }
        
        if (!defaultDetailTextLabelHighlightedTextColor)
        {
            defaultDetailTextLabelHighlightedTextColor = cell.detailTextLabel.highlightedTextColor;
        }
        
        if (editing) {
            cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
            cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
        } else {
            cell.textLabel.highlightedTextColor = defaultTextLabelHighlightedTextColor;
            cell.detailTextLabel.highlightedTextColor = defaultDetailTextLabelHighlightedTextColor;
        }
    }
    
    self.navigationItem.leftBarButtonItem = (editing) ? self.editButtonItem : nil;
    [self.navigationController setToolbarHidden:!editing animated:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    CGPoint point = [gesture locationInView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
    
    if (!index)
    {
        return;
    }
    
    if (!self.isEditing)
    {
        [self setEditing:YES animated:YES];
    }

    [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
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

- (void)fetchFullManga
{
    __weak typeof(self) weakSelf = self;
    [self.mangaService fetchFullMangaWithId:self.manga.id_ completion:^(YGRManga *manga, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!manga || error)
        {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.manga = manga;
            
            if (manga.lastChapterRead != nil)
            {
                strongSelf.continueButton.enabled = YES;
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchChapters];
    [self fetchFullManga];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%d Chapter%@", self.chapters.count, self.chapters.count == 1 ? @"" : @"s"];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    YGRChapter *selectedChapter = [self.chapters objectAtIndex:indexPath.row];
    cell.textLabel.text = selectedChapter.name;
    
    if (selectedChapter.read)
    {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    NSDate *uploadDate = [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval)selectedChapter.uploadDate/1000];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:uploadDate];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isEditing) {
        return;
    }
    
    NSArray *selected = [tableView indexPathsForSelectedRows];
    if (selected.count == 0) {
        [self setEditing:NO animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing)
    {
        return;
    }
    
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

#pragma mark - Manga Info

- (void)showMangaInfo
{
    YGRMangaInfoViewController *infoVC = [[YGRMangaInfoViewController alloc] init];
    infoVC.mangaId = self.manga.id_;
    [self.navigationController pushViewController:infoVC animated:YES];
}

@end
