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
#import "YGRPullToRefreshView.h"

@interface YGRLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate,
                                        UIActionSheetDelegate, YGRPullToRefreshDelegate>

@property (nonatomic, strong) YGRLibraryViewModel *viewModel;

@property (nonatomic, strong) YGRPullToRefreshView *pullToRefreshView;

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) CGSize portraitCellSize;

@end

@implementation YGRLibraryViewController

#pragma mark - Init

- (instancetype)init
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

    [self configureActionSheet];
    [self configureGridView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchLibrary];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UI Configuration

/**
 *  Builds the action sheet presented on a long press, offering delete,
 *  read, and unread actions for the selected manga.
 */
- (void)configureActionSheet
{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Edit"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:@"Read", @"Unread", nil];
}

/**
 *  Configures the grid view's data source, delegate, and appearance, and
 *  attaches the long-press gesture recognizer used to trigger the edit
 *  action sheet.
 */
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

    self.pullToRefreshView = [[YGRPullToRefreshView alloc] initWithScrollView:self.gridView];
    self.pullToRefreshView.delegate = self;
}

#pragma mark - AQGridViewDelegate (scroll tracking)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullToRefreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullToRefreshView scrollViewDidEndDragging];
}

#pragma mark - YGRPullToRefreshDelegate

- (void)pullToRefreshViewDidTriggerRefresh:(YGRPullToRefreshView *)pullToRefreshView
{
    [self fetchLibrary];
}

#pragma mark - Long Press & Action Sheet

/**
 *  Presents the edit action sheet for the manga under a long press.
 *
 *  @param gesture The long-press gesture recognizer that triggered this handler.
 */
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
                                  if (!strongSelf) return;

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
                                     if (!strongSelf) return;

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
                                       if (!strongSelf) return;

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

#pragma mark - Data Fetching

/**
 *  Fetches the current library from the view model and reloads the grid
 *  view, collapsing the pull-to-refresh header and showing an error alert
 *  on failure.
 */
- (void)fetchLibrary
{
    __weak typeof(self) weakSelf = self;

    [self.viewModel fetchLibraryWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            [strongSelf.pullToRefreshView finishLoading];

            if (error)
            {
                [strongSelf showErrorAlertWithMessage:@"Failed to fetch library"];
                return;
            }

            [strongSelf.gridView reloadData];
        });
    }];
}

/**
 *  Re-fetches the library; invoked after a bulk mark-read/unread action.
 */
- (void)refreshLibrary
{
    [self fetchLibrary];
}

#pragma mark - Error Handling

/**
 *  Presents a simple alert with the given message and an OK button.
 *
 *  @param message The message to display in the alert body.
 */
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

/**
 *  Dequeues (or creates) a library cell and populates it with the manga's
 *  title and unread count, then asynchronously fetches its thumbnail,
 *  guarding against the cell having been reused for a different manga by
 *  the time the fetch completes.
 */
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
