//
//  YGRSourceLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/16.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//  Updated to add a UICollectionView path for iOS 6+ 2026/09/09
//

#import "YGRSourceLibraryViewController.h"
#import "YGRSourceLibraryViewModel.h"
#import "YGRMangaViewController.h"

#import "YGRImageService.h"
#import "YGRLibraryCell.h"
#import "YGRLibraryCollectionViewCell.h"
#import "YGRMangaSplitViewController.h"

#import <AQGridView/AQGridView.h>

static NSString *const kYGRLibraryCellIdentifier = @"LibraryCell";

@interface YGRSourceLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate,
                                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
                                              UISearchBarDelegate>

@property (nonatomic, strong) YGRSourceLibraryViewModel *viewModel;

@property (nonatomic, strong) UISegmentedControl *mangaListSegmentedControl;
@property (nonatomic, strong) UISearchBar *mangaSearchBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

// On iOS 6+, `libraryCollectionView` is used and `libraryGridView` is nil;
// on iOS 5, `libraryGridView` is used and `libraryCollectionView` is nil.
// See -usesCollectionView and -itemsScrollView.
@property (nonatomic, assign) BOOL usesCollectionView;
@property (nonatomic, strong) AQGridView *libraryGridView;
@property (nonatomic, strong) UICollectionView *libraryCollectionView;

@property (nonatomic, assign) CGSize portraitCellSize;

@end

@implementation YGRSourceLibraryViewController

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _viewModel = [[YGRSourceLibraryViewModel alloc] init];
        _usesCollectionView = (NSClassFromString(@"UICollectionView") != nil);

        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;

        int columnCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 2;
        CGFloat cellWidth = screenWidth / columnCount;

        _portraitCellSize = CGSizeMake(cellWidth, cellWidth * 1.25);
    }
    return self;
}

#pragma mark - Properties

- (void)setSource:(YGRSource *)source
{
    _source = source;
    self.viewModel.source = source;
}

/**
 *  The active scroll view, whichever grid technology is in use. Both
 *  AQGridView and UICollectionView are UIScrollView subclasses.
 */
- (UIScrollView *)itemsScrollView
{
    return self.usesCollectionView ? (UIScrollView *)self.libraryCollectionView
                                    : (UIScrollView *)self.libraryGridView;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.source.displayName;
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                      target:self
                                                      action:@selector(showSearchBar)];

    self.view.backgroundColor = [UIColor whiteColor];

    [self configureSegmentedControl];
    [self configureSearchBar];
    [self configureGridView];
    [self configureLoadingSpinner];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchMangaListForSelectedSegment];
}

#pragma mark - UI Configuration

/**
 *  Builds the Popular/Latest segmented control and adds it to the view.
 */
- (void)configureSegmentedControl
{
    self.mangaListSegmentedControl =
        [[UISegmentedControl alloc] initWithItems:@[ @"Popular", @"Latest" ]];
    self.mangaListSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.mangaListSegmentedControl addTarget:self
                                       action:@selector(mangaListDidChange:)
                             forControlEvents:UIControlEventValueChanged];
    self.mangaListSegmentedControl.selectedSegmentIndex = 0;

    CGFloat padding = 8.0f;
    CGFloat height = 32.0f;

    self.mangaListSegmentedControl.frame =
        CGRectMake(padding, padding, self.view.bounds.size.width - (padding * 2), height);

    self.mangaListSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.mangaListSegmentedControl];
}

/**
 *  Builds the search bar, sized to match the segmented control's frame. Not
 *  added to the view here; it is swapped in when the search button is tapped.
 */
- (void)configureSearchBar
{
    self.mangaSearchBar = [[UISearchBar alloc] initWithFrame:self.mangaListSegmentedControl.frame];
    self.mangaSearchBar.barStyle = UIBarStyleBlackTranslucent;
    self.mangaSearchBar.delegate = self;
    self.mangaSearchBar.showsCancelButton = YES;
    self.mangaSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

/**
 *  Builds whichever grid technology is active (UICollectionView on iOS 6+,
 *  AQGridView on iOS 5) below the segmented control, and attaches the
 *  long-press gesture recognizer used to toggle a manga's library status.
 */
- (void)configureGridView
{
    CGFloat top = CGRectGetMaxY(self.mangaListSegmentedControl.frame) + 8.0f;

    CGRect contentViewFrame =
        CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top);

    if (self.usesCollectionView)
    {
        [self configureCollectionViewWithFrame:contentViewFrame];
    }
    else
    {
        [self configureAQGridViewWithFrame:contentViewFrame];
    }

    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.itemsScrollView addGestureRecognizer:longPress];
}

- (void)configureAQGridViewWithFrame:(CGRect)frame
{
    self.libraryGridView = [[AQGridView alloc] initWithFrame:frame];
    self.libraryGridView.dataSource = self;
    self.libraryGridView.delegate = self;
    self.libraryGridView.backgroundColor = [UIColor whiteColor];
    self.libraryGridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    self.libraryGridView.bounces = YES;
    self.libraryGridView.alwaysBounceVertical = YES;
    self.libraryGridView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.libraryGridView];
}

- (void)configureCollectionViewWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = self.portraitCellSize;

    self.libraryCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.libraryCollectionView.dataSource = self;
    self.libraryCollectionView.delegate = self;
    self.libraryCollectionView.backgroundColor = [UIColor whiteColor];
    self.libraryCollectionView.alwaysBounceVertical = YES;
    self.libraryCollectionView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.libraryCollectionView registerClass:[YGRLibraryCollectionViewCell class]
                    forCellWithReuseIdentifier:kYGRLibraryCellIdentifier];
    [self.view addSubview:self.libraryCollectionView];
}

/**
 *  Builds the loading spinner and centers it over the grid view.
 */
- (void)configureLoadingSpinner
{
    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect gridBounds = self.itemsScrollView.bounds;
    self.loadingSpinner.center =
        CGPointMake(gridBounds.size.width / 2.0f, gridBounds.size.height / 2.0f);
    [self.itemsScrollView addSubview:self.loadingSpinner];
}

#pragma mark - Search Bar

/**
 *  Swaps the segmented control out for the search bar and focuses it.
 */
- (void)showSearchBar
{
    [self.mangaListSegmentedControl removeFromSuperview];
    [self.view addSubview:self.mangaSearchBar];
    [self.mangaSearchBar becomeFirstResponder];
}

/**
 *  Swaps the search bar out for the segmented control.
 */
- (void)hideSearchBar
{
    [self.mangaSearchBar removeFromSuperview];
    [self.view addSubview:self.mangaListSegmentedControl];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.viewModel resetPagination];
    [self.itemsScrollView setContentOffset:CGPointZero animated:NO];

    [self showLoadingSpinnerIfEmpty];

    __weak typeof(self) weakSelf = self;
    [self.viewModel searchMangaWithTerm:searchBar.text
                             completion:^(NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     __strong typeof(weakSelf) strongSelf = weakSelf;
                                     if (!strongSelf) return;

                                     [strongSelf hideLoadingSpinner];

                                     if (error)
                                     {
                                         [strongSelf showErrorAlertWithMessage:@"Failed to search manga"];
                                         return;
                                     }

                                     [strongSelf reloadItems];
                                 });
                             }];

    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchBar];
    [self mangaListDidChange:self.mangaListSegmentedControl];
}

#pragma mark - Data Fetching

/**
 *  Fetches the popular or latest manga list, depending on which segment of
 *  the segmented control is currently selected, and reloads the grid.
 */
- (void)fetchMangaListForSelectedSegment
{
    YGRSourceLibraryListType listType =
        (YGRSourceLibraryListType)self.mangaListSegmentedControl.selectedSegmentIndex;

    [self showLoadingSpinnerIfEmpty];

    __weak typeof(self) weakSelf = self;
    [self.viewModel fetchMangaListOfType:listType
                              completion:^(NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      if (!strongSelf) return;

                                      [strongSelf hideLoadingSpinner];

                                      if (error)
                                      {
                                          NSString *message = (listType == YGRSourceLibraryListTypePopular)
                                                                  ? @"Failed to fetch popular manga"
                                                                  : @"Failed to fetch latest manga";
                                          [strongSelf showErrorAlertWithMessage:message];
                                          return;
                                      }

                                      [strongSelf reloadItems];
                                  });
                              }];
}

/**
 *  Handles a change in the Popular/Latest segmented control by resetting
 *  pagination and re-fetching the list for the newly selected segment.
 *
 *  @param sender The segmented control that changed value.
 */
- (void)mangaListDidChange:(UISegmentedControl *)sender
{
    [self.viewModel resetPagination];
    [self.itemsScrollView setContentOffset:CGPointZero animated:NO];
    [self fetchMangaListForSelectedSegment];
}

- (void)reloadItems
{
    if (self.usesCollectionView)
    {
        [self.libraryCollectionView reloadData];
    }
    else
    {
        [self.libraryGridView reloadData];
    }
}

#pragma mark - Long Press (Library Toggle)

/**
 *  Toggles the library status of the manga under a long press once the
 *  gesture begins, reloading just that grid cell on success.
 *
 *  @param gesture The long-press gesture recognizer attached to the grid view.
 */
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }

    CGPoint point = [gesture locationInView:self.itemsScrollView];

    NSUInteger index;

    if (self.usesCollectionView)
    {
        NSIndexPath *indexPath = [self.libraryCollectionView indexPathForItemAtPoint:point];
        if (!indexPath)
        {
            return;
        }
        index = (NSUInteger)indexPath.item;
    }
    else
    {
        NSInteger foundIndex = [self.libraryGridView indexForItemAtPoint:point];
        if (foundIndex == NSNotFound)
        {
            return;
        }
        index = (NSUInteger)foundIndex;
    }

    YGRManga *selectedManga = [self.viewModel mangaAtIndex:index];
    NSString *errorMessage = selectedManga.inLibrary ? @"Failed to remove manga from library"
                                                     : @"Failed to add manga to library";

    __weak typeof(self) weakSelf = self;
    [self.viewModel
        toggleLibraryStatusAtIndex:index
                        completion:^(BOOL success, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                if (!strongSelf) return;

                                if (!success || error)
                                {
                                    [strongSelf showErrorAlertWithMessage:errorMessage];
                                    return;
                                }

                                [strongSelf reloadItemAtIndex:index];
                            });
                        }];
}

- (void)reloadItemAtIndex:(NSUInteger)index
{
    if (self.usesCollectionView)
    {
        [self.libraryCollectionView reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index
                                                                                     inSection:0] ]];
    }
    else
    {
        [self.libraryGridView reloadItemsAtIndices:[NSIndexSet indexSetWithIndex:index]
                                     withAnimation:AQGridViewItemAnimationFade];
    }
}

#pragma mark - Loading Spinner

/**
 *  Starts the loading spinner, but only if the grid has no items yet — an
 *  in-place refresh (e.g. pagination) leaves existing items visible.
 */
- (void)showLoadingSpinnerIfEmpty
{
    if ([self.viewModel numberOfItems] == 0)
    {
        [self.loadingSpinner startAnimating];
    }
}

/**
 *  Stops the loading spinner.
 */
- (void)hideLoadingSpinner
{
    [self.loadingSpinner stopAnimating];
}

#pragma mark - Error Handling

/**
 *  Presents a simple error alert with an OK button.
 *
 *  @param message The message body to display in the alert.
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat preloadMargin = self.portraitCellSize.height * 2.0f;

    if (scrollView.contentOffset.y + scrollView.bounds.size.height >=
        scrollView.contentSize.height - preloadMargin)
    {
        [self loadNextPageIfNeeded];
    }
}

/**
 *  Loads the next page of results if the view model has one and isn't
 *  already loading, reloading the grid on success.
 */
- (void)loadNextPageIfNeeded
{
    if (![self.viewModel hasNextPage] || self.viewModel.isLoading)
    {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.viewModel loadNextPageWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (error)
            {
                return;
            }

            [strongSelf reloadItems];
        });
    }];
}

#pragma mark - Shared Cell Configuration

- (void)configureCell:(id<YGRLibraryCellDisplaying>)cell atIndex:(NSUInteger)index
{
    YGRManga *manga = [self.viewModel mangaAtIndex:index];
    cell.title = manga.title;

    if (manga.inLibrary)
    {
        [cell showBorder];
    }
    else
    {
        [cell hideBorder];
    }

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

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
