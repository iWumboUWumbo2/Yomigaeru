//
//  YGRLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Updated for AQGridView ARC 2026/01/14
//  Updated to add a UICollectionView path for iOS 6+ 2026/09/09
//

#import "YGRLibraryViewController.h"
#import "YGRLibraryViewModel.h"
#import "YGRMangaViewController.h"

#import "YGRImageService.h"
#import "YGRLibraryCell.h"
#import "YGRLibraryCollectionViewCell.h"
#import "YGRMangaSplitViewController.h"
#import "YGRPullToRefreshView.h"

#import <AQGridView/AQGridView.h>

static NSString *const kYGRLibraryCellIdentifier = @"LibraryCell";

@interface YGRLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate,
                                        UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
                                        UIActionSheetDelegate, YGRPullToRefreshDelegate>

@property (nonatomic, strong) YGRLibraryViewModel *viewModel;

@property (nonatomic, strong) YGRPullToRefreshView *pullToRefreshView;

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) CGSize portraitCellSize;

// On iOS 6+, `collectionView` is used and `gridView` is nil; on iOS 5,
// `gridView` is used and `collectionView` is nil. See -[YGRLibraryViewController
// usesCollectionView] and -itemsScrollView.
@property (nonatomic, assign) BOOL usesCollectionView;
@property (nonatomic, strong) AQGridView *gridView;
@property (nonatomic, strong) UICollectionView *collectionView;

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
        _usesCollectionView = (NSClassFromString(@"UICollectionView") != nil);

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
 *  Builds whichever grid technology is active (UICollectionView on iOS 6+,
 *  AQGridView on iOS 5), attaches the long-press gesture recognizer used to
 *  trigger the edit action sheet, and wires up pull-to-refresh.
 */
- (void)configureGridView
{
    if (self.usesCollectionView)
    {
        [self configureCollectionView];
    }
    else
    {
        [self configureAQGridView];
    }

    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.itemsScrollView addGestureRecognizer:longPress];

    self.pullToRefreshView = [[YGRPullToRefreshView alloc] initWithScrollView:self.itemsScrollView];
    self.pullToRefreshView.delegate = self;
}

- (void)configureAQGridView
{
    self.gridView = [[AQGridView alloc] initWithFrame:self.view.bounds];
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.backgroundColor = [UIColor whiteColor];
    self.gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    self.gridView.bounces = YES;
    self.gridView.alwaysBounceVertical = YES;
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.gridView];
}

- (void)configureCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = self.portraitCellSize;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                               collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.collectionView registerClass:[YGRLibraryCollectionViewCell class]
             forCellWithReuseIdentifier:kYGRLibraryCellIdentifier];
    [self.view addSubview:self.collectionView];
}

/**
 *  The active scroll view, whichever grid technology is in use. Both
 *  AQGridView and UICollectionView are UIScrollView subclasses.
 */
- (UIScrollView *)itemsScrollView
{
    return self.usesCollectionView ? (UIScrollView *)self.collectionView : (UIScrollView *)self.gridView;
}

#pragma mark - Scroll Tracking

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

    CGPoint point = [gesture locationInView:self.itemsScrollView];

    NSUInteger index;
    CGRect itemRect;

    if (self.usesCollectionView)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (!indexPath)
        {
            return;
        }
        index = (NSUInteger)indexPath.item;
        itemRect = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    }
    else
    {
        NSInteger foundIndex = [self.gridView indexForItemAtPoint:point];
        if (foundIndex == NSNotFound)
        {
            return;
        }
        index = (NSUInteger)foundIndex;
        itemRect = [self.gridView rectForItemAtIndex:index];
    }

    self.selectedIndex = index;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.actionSheet showFromRect:itemRect inView:self.view animated:YES];
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

                                  [strongSelf deleteItemAtIndex:strongSelf.selectedIndex];
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

- (void)deleteItemAtIndex:(NSUInteger)index
{
    if (self.usesCollectionView)
    {
        [self.collectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
    }
    else
    {
        [self.gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:index]
                              withAnimation:AQGridViewItemAnimationFade];
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

            [strongSelf reloadItems];
        });
    }];
}

- (void)reloadItems
{
    if (self.usesCollectionView)
    {
        [self.collectionView reloadData];
    }
    else
    {
        [self.gridView reloadData];
    }
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

#pragma mark - Shared Cell Configuration

/**
 *  Populates a library cell (either grid technology, via the shared
 *  YGRLibraryCellDisplaying interface) with the manga's title and unread
 *  count, then asynchronously fetches its thumbnail, guarding against the
 *  cell having been reused for a different manga by the time the fetch
 *  completes.
 */
- (void)configureCell:(id<YGRLibraryCellDisplaying>)cell atIndex:(NSUInteger)index
{
    YGRManga *manga = [self.viewModel mangaAtIndex:index];
    cell.title = manga.title;
    cell.unreadCount = manga.unreadCount;
    cell.image = [UIImage imageNamed:@"placeholder"];
    [cell showLoadingSpinner];

    __weak id<YGRLibraryCellDisplaying> weakCell = cell;
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
}

- (void)navigateToMangaAtIndex:(NSUInteger)index
{
    YGRManga *selectedManga = [self.viewModel mangaAtIndex:index];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        YGRMangaSplitViewController *splitVC =
            [[YGRMangaSplitViewController alloc] initWithManga:selectedManga];
        [self presentViewController:splitVC animated:YES completion:nil];
        return;
    }

    YGRMangaViewController *mangaVC = [[YGRMangaViewController alloc] init];
    mangaVC.manga = selectedManga;

    [self.navigationController pushViewController:mangaVC animated:YES];
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
    YGRLibraryCell *cell =
        (YGRLibraryCell *)[gridView dequeueReusableCellWithIdentifier:kYGRLibraryCellIdentifier];

    if (!cell)
    {
        CGSize cellSize = self.portraitCellSize;

        cell =
            [[YGRLibraryCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)
                                  reuseIdentifier:kYGRLibraryCellIdentifier];
        cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }

    [self configureCell:cell atIndex:index];

    return cell;
}

#pragma mark - AQGridViewDelegate

- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index
{
    [gridView deselectItemAtIndex:index animated:YES];
    [self navigateToMangaAtIndex:index];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGRLibraryCollectionViewCell *cell =
        (YGRLibraryCollectionViewCell *)[collectionView
            dequeueReusableCellWithReuseIdentifier:kYGRLibraryCellIdentifier
                                       forIndexPath:indexPath];

    [self configureCell:cell atIndex:(NSUInteger)indexPath.item];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.portraitCellSize;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self navigateToMangaAtIndex:(NSUInteger)indexPath.item];
}

@end
