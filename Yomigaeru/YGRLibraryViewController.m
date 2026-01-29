//
//  YGRLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Updated for AQGridView ARC 2026/01/14
//

#import "YGRLibraryViewController.h"
#import "YGRLibraryViewModel.h"
#import "YGRMangaViewController.h"

#import "YGRImageService.h"
#import "YGRLibraryCell.h"

@interface YGRLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate,
                                        UIActionSheetDelegate>

@property (nonatomic, strong) YGRLibraryViewModel *viewModel;

@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) CGSize portraitCellSize;

@end

@implementation YGRLibraryViewController

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _viewModel = [[YGRLibraryViewModel alloc] init];
        _selectedIndex = NSNotFound;

        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;

        int columnCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 2;
        CGFloat cellWidth = screenWidth / columnCount;

        _portraitCellSize = CGSizeMake(cellWidth, cellWidth * 1.25);
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Library";

    [self configureNavigationBar];
    [self configureActionSheet];
    [self configureGridView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchLibrary];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self disableSpinner];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UI Configuration

- (void)configureNavigationBar
{
    self.refreshButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                      target:self
                                                      action:@selector(refreshLibrary)];
    self.refreshSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = self.refreshButton;
}

- (void)configureActionSheet
{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Edit"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:@"Mark Read", @"Mark Unread", nil];
}

- (void)configureGridView
{
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.backgroundColor = [UIColor whiteColor];
    self.gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    self.gridView.bounces = YES;
    self.gridView.alwaysBounceVertical = YES;

    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.gridView addGestureRecognizer:longPress];
}

#pragma mark - Long Press & Action Sheet

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }

    CGPoint point = [gesture locationInView:self.gridView];
    NSInteger index = [self.gridView indexForItemAtPoint:point];

    if (index == NSNotFound)
    {
        return;
    }

    self.selectedIndex = index;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.actionSheet showFromRect:[self.gridView rectForItemAtIndex:index]
                                inView:self.view
                              animated:YES];
    }
    else
    {
        [self.actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger markReadButtonIndex = actionSheet.firstOtherButtonIndex;
    NSInteger markUnreadButtonIndex = markReadButtonIndex + 1;

    __weak typeof(self) weakSelf = self;

    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self.viewModel
            deleteFromLibraryAtIndex:self.selectedIndex
                          completion:^(BOOL success, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  __strong typeof(weakSelf) strongSelf = weakSelf;

                                  if (!success || error)
                                  {
                                      [strongSelf showErrorAlertWithMessage:@"Failed to delete manga"];
                                      return;
                                  }

                                  [strongSelf.gridView
                                      deleteItemsAtIndices:[NSIndexSet
                                                               indexSetWithIndex:strongSelf.selectedIndex]
                                             withAnimation:AQGridViewItemAnimationFade];
                              });
                          }];
    }
    else if (buttonIndex == markReadButtonIndex)
    {
        [self.viewModel markReadAtIndex:self.selectedIndex
                             completion:^(BOOL success, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     __strong typeof(weakSelf) strongSelf = weakSelf;

                                     if (!success || error)
                                     {
                                         [strongSelf
                                             showErrorAlertWithMessage:@"Failed to mark manga as read"];
                                         return;
                                     }

                                     [strongSelf refreshLibrary];
                                 });
                             }];
    }
    else if (buttonIndex == markUnreadButtonIndex)
    {
        [self.viewModel markUnreadAtIndex:self.selectedIndex
                               completion:^(BOOL success, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       __strong typeof(weakSelf) strongSelf = weakSelf;

                                       if (!success || error)
                                       {
                                           [strongSelf showErrorAlertWithMessage:
                                                           @"Failed to mark manga as unread"];
                                           return;
                                       }

                                       [strongSelf refreshLibrary];
                                   });
                               }];
    }
}

#pragma mark - Spinner

- (void)enableSpinner
{
    if (![self.refreshSpinner isAnimating])
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self.refreshSpinner startAnimating];
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithCustomView:self.refreshSpinner];
    }
}

- (void)disableSpinner
{
    if ([self.refreshSpinner isAnimating])
    {
        [self.refreshSpinner stopAnimating];
        self.navigationItem.leftBarButtonItem = self.refreshButton;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

#pragma mark - Data Fetching

- (void)fetchLibrary
{
    __weak typeof(self) weakSelf = self;

    [self.viewModel fetchLibraryWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;

            [strongSelf disableSpinner];

            if (error)
            {
                [strongSelf showErrorAlertWithMessage:@"Failed to fetch library"];
                return;
            }

            [strongSelf.gridView reloadData];
        });
    }];
}

- (void)refreshLibrary
{
    [self enableSpinner];
    [self fetchLibrary];
}

#pragma mark - Error Handling

- (void)showErrorAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - AQGridViewDataSource

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView
{
    return [self.viewModel numberOfItems];
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView
{
    return self.portraitCellSize;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString *CellIdentifier = @"LibraryCell";

    YGRLibraryCell *cell =
        (YGRLibraryCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        CGSize cellSize = [self portraitGridCellSizeForGridView:self.gridView];

        cell =
            [[YGRLibraryCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)
                                  reuseIdentifier:CellIdentifier];
        cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }

    YGRManga *manga = [self.viewModel mangaAtIndex:index];
    cell.title = manga.title;
    cell.unreadCount = manga.unreadCount;
    cell.image = [UIImage imageNamed:@"placeholder"];
    [cell showLoadingSpinner];

    __weak typeof(cell) weakCell = cell;
    [[YGRImageService sharedService]
        fetchThumbnailWithMangaId:manga.id_
                       completion:^(UIImage *thumbnailImage, NSError *error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if ([weakCell.title isEqualToString:manga.title])
                               {
                                   [weakCell hideLoadingSpinner];
                                   if (!error && thumbnailImage)
                                   {
                                       weakCell.image = thumbnailImage;
                                   }
                               }
                           });
                       }];

    return cell;
}

#pragma mark - AQGridViewDelegate

- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index
{
    [gridView deselectItemAtIndex:index animated:YES];

    YGRManga *selectedManga = [self.viewModel mangaAtIndex:index];
    YGRMangaViewController *mangaVC = [[YGRMangaViewController alloc] init];
    mangaVC.manga = selectedManga;

    [self.navigationController pushViewController:mangaVC animated:YES];
}

@end
