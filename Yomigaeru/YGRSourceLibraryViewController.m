//
//  YGRSourceLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/16.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourceLibraryViewController.h"
#import "YGRSourceLibraryViewModel.h"
#import "YGRMangaViewController.h"

#import "YGRImageService.h"
#import "YGRLibraryCell.h"

#import <AQGridView/AQGridView.h>

@interface YGRSourceLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate,
                                              UISearchBarDelegate>

@property (nonatomic, strong) YGRSourceLibraryViewModel *viewModel;

@property (nonatomic, strong) UISegmentedControl *mangaListSegmentedControl;
@property (nonatomic, strong) UISearchBar *mangaSearchBar;
@property (nonatomic, strong) AQGridView *libraryGridView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, assign) CGSize portraitCellSize;

@end

@implementation YGRSourceLibraryViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        _viewModel = [[YGRSourceLibraryViewModel alloc] init];

        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;

        int columnCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 2;
        CGFloat cellWidth = screenWidth / columnCount;

        _portraitCellSize = CGSizeMake(cellWidth, cellWidth * 1.25);
    }
    return self;
}

- (void)setSource:(YGRSource *)source
{
    _source = source;
    self.viewModel.source = source;
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

- (void)configureSearchBar
{
    self.mangaSearchBar = [[UISearchBar alloc] initWithFrame:self.mangaListSegmentedControl.frame];
    self.mangaSearchBar.barStyle = UIBarStyleBlackTranslucent;
    self.mangaSearchBar.delegate = self;
    self.mangaSearchBar.showsCancelButton = YES;
    self.mangaSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)configureGridView
{
    CGFloat top = CGRectGetMaxY(self.mangaListSegmentedControl.frame) + 8.0f;

    CGRect contentViewFrame =
        CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top);

    self.libraryGridView = [[AQGridView alloc] initWithFrame:contentViewFrame];
    self.libraryGridView.dataSource = self;
    self.libraryGridView.delegate = self;
    self.libraryGridView.backgroundColor = [UIColor whiteColor];
    self.libraryGridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    self.libraryGridView.bounces = YES;
    self.libraryGridView.alwaysBounceVertical = YES;
    self.libraryGridView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.libraryGridView];

    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.libraryGridView addGestureRecognizer:longPress];
}

- (void)configureLoadingSpinner
{
    self.loadingSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect gridBounds = self.libraryGridView.bounds;
    self.loadingSpinner.center =
        CGPointMake(gridBounds.size.width / 2.0f, gridBounds.size.height / 2.0f);
    [self.libraryGridView addSubview:self.loadingSpinner];
}

#pragma mark - Search Bar

- (void)showSearchBar
{
    [self.mangaListSegmentedControl removeFromSuperview];
    [self.view addSubview:self.mangaSearchBar];
    [self.mangaSearchBar becomeFirstResponder];
}

- (void)hideSearchBar
{
    [self.mangaSearchBar removeFromSuperview];
    [self.view addSubview:self.mangaListSegmentedControl];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.viewModel resetPagination];
    [self.libraryGridView setContentOffset:CGPointZero animated:NO];

    [self showLoadingSpinnerIfEmpty];

    __weak typeof(self) weakSelf = self;
    [self.viewModel searchMangaWithTerm:searchBar.text
                             completion:^(NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     __strong typeof(weakSelf) strongSelf = weakSelf;
                                     [strongSelf hideLoadingSpinner];

                                     if (error)
                                     {
                                         [strongSelf showErrorAlertWithMessage:@"Failed to search manga"];
                                         return;
                                     }

                                     [strongSelf.libraryGridView reloadData];
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
                                      [strongSelf hideLoadingSpinner];

                                      if (error)
                                      {
                                          NSString *message = (listType == YGRSourceLibraryListTypePopular)
                                                                  ? @"Failed to fetch popular manga"
                                                                  : @"Failed to fetch latest manga";
                                          [strongSelf showErrorAlertWithMessage:message];
                                          return;
                                      }

                                      [strongSelf.libraryGridView reloadData];
                                  });
                              }];
}

- (void)mangaListDidChange:(UISegmentedControl *)sender
{
    [self.viewModel resetPagination];
    [self.libraryGridView setContentOffset:CGPointZero animated:NO];
    [self fetchMangaListForSelectedSegment];
}

#pragma mark - Long Press (Library Toggle)

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }

    CGPoint point = [gesture locationInView:self.libraryGridView];
    NSInteger index = [self.libraryGridView indexForItemAtPoint:point];

    if (index == NSNotFound)
    {
        return;
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

                                if (!success || error)
                                {
                                    [strongSelf showErrorAlertWithMessage:errorMessage];
                                    return;
                                }

                                [strongSelf.libraryGridView
                                    reloadItemsAtIndices:[NSIndexSet indexSetWithIndex:index]
                                           withAnimation:AQGridViewItemAnimationFade];
                            });
                        }];
}

#pragma mark - Loading Spinner

- (void)showLoadingSpinnerIfEmpty
{
    if ([self.viewModel numberOfItems] == 0)
    {
        [self.loadingSpinner startAnimating];
    }
}

- (void)hideLoadingSpinner
{
    [self.loadingSpinner stopAnimating];
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

            if (error)
            {
                return;
            }

            [strongSelf.libraryGridView reloadData];
        });
    }];
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
        CGSize cellSize = [self portraitGridCellSizeForGridView:self.libraryGridView];

        cell =
            [[YGRLibraryCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)
                                  reuseIdentifier:CellIdentifier];
        cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
