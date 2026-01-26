//
//  YGRLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Updated for AQGridView ARC 2026/01/14
//

#import "YGRLibraryViewController.h"
#import "YGRMangaViewController.h"

#import "YGRCategoryService.h"
#import "YGRImageService.h"
#import "YGRLibraryCell.h"
#import "YGRManga.h"
#import "YGRMangaService.h"

@interface YGRLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate,
                                        UIActionSheetDelegate>

@property (nonatomic, strong) YGRCategoryService *categoryService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangas;

@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation YGRLibraryViewController

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _categoryService = [[YGRCategoryService alloc] init];
        _mangaService = [[YGRMangaService alloc] init];
        _mangas = [NSMutableArray array];
        _selectedIndex = NSNotFound;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Library";

    // Refresh button & spinner
    self.refreshButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                      target:self
                                                      action:@selector(refreshLibrary)];
    self.refreshSpinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = self.refreshButton;

    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Edit"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:@"Mark Read", @"Mark Unread", nil];

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

#pragma mark - Library Loading

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
        // In this case the device is an iPad.
        [self.actionSheet showFromRect:[self.gridView rectForItemAtIndex:index]
                                inView:self.view
                              animated:YES];
    }
    else
    {
        // In this case the device is an iPhone/iPod Touch.
        [self.actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    YGRManga *selectedManga = [self.mangas objectAtIndex:self.selectedIndex];

    NSInteger markReadButtonIndex = actionSheet.firstOtherButtonIndex;
    NSInteger markUnreadButtonIndex = markReadButtonIndex + 1;

    __weak typeof(self) weakSelf = self;

    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self.mangaService
            deleteFromLibraryWithMangaId:selectedManga.id_
                              completion:^(BOOL success, NSError *error) {
                                  __strong typeof(weakSelf) strongSelf = weakSelf;

                                  if (error || !success)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"Error"
                                                        message:@"Failed to delete manga"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                                          [alert show];
                                      });
                                      return;
                                  }

                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [strongSelf.mangas
                                          removeObjectAtIndex:strongSelf.selectedIndex];
                                      [strongSelf.gridView
                                          deleteItemsAtIndices:
                                              [NSIndexSet
                                                  indexSetWithIndex:strongSelf.selectedIndex]
                                                 withAnimation:AQGridViewItemAnimationFade];
                                  });
                              }];
    }

    else if (buttonIndex == markReadButtonIndex)
    {
        [self.mangaService
            markMangaReadStatusWithMangaId:selectedManga.id_
                                readStatus:YES
                                completion:^(BOOL success, NSError *error) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;

                                    if (error || !success)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIAlertView *alert = [[UIAlertView alloc]
                                                    initWithTitle:@"Error"
                                                          message:@"Failed to mark manga as read"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
                                            [alert show];
                                        });
                                        return;
                                    }

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       // TODO
                                                   });
                                }];
    }

    else if (buttonIndex == markUnreadButtonIndex)
    {
        [self.mangaService
            markMangaReadStatusWithMangaId:selectedManga.id_
                                readStatus:NO
                                completion:^(BOOL success, NSError *error) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;

                                    if (error || !success)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIAlertView *alert = [[UIAlertView alloc]
                                                    initWithTitle:@"Error"
                                                          message:@"Failed to mark manga as unread"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
                                            [alert show];
                                        });
                                        return;
                                    }

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       // TODO
                                                   });
                                }];
    }
}

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

- (void)fetchLibrary
{
    __weak typeof(self) weakSelf = self;

    [self.categoryService fetchLibraryWithCompletion:^(NSArray *mangas, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
            return;

        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf disableSpinner];
        });

        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Failed to fetch library"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
            return;
        }

        strongSelf.mangas = [NSMutableArray arrayWithArray:mangas];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.gridView reloadData];
        });
    }];
}

- (void)refreshLibrary
{
    [self enableSpinner];
    [self fetchLibrary];
}

#pragma mark - AQGridView DataSource

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView
{
    return !self.mangas ? 0 : self.mangas.count;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;

    int columnCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 2;
    CGFloat cellWidth = screenWidth / columnCount;

    return CGSizeMake(cellWidth, cellWidth * 1.25);
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString *CellIdentifier = @"LibraryCell";

    YGRLibraryCell *cell =
        (YGRLibraryCell *) [gridView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        CGSize cellSize = [self portraitGridCellSizeForGridView:self.gridView];

        cell =
            [[YGRLibraryCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)
                                  reuseIdentifier:CellIdentifier];
        cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }

    YGRManga *manga = [self.mangas objectAtIndex:index];
    cell.title = manga.title;

    cell.image = [UIImage imageNamed:@"placeholder"];
    [cell showLoadingSpinner];

    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    [[YGRImageService sharedService]
        fetchThumbnailWithMangaId:manga.id_
                       completion:^(UIImage *thumbnailImage, NSError *error) {
                           __strong typeof(weakSelf) strongSelf = weakSelf;
                           if (!strongSelf)
                               return;

                           dispatch_async(dispatch_get_main_queue(), ^{
                               // Ensure the cell still represents the same manga
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

#pragma mark - AQGridView Delegate

- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index
{
    [gridView deselectItemAtIndex:index animated:YES];

    YGRManga *selectedManga = [self.mangas objectAtIndex:index];
    YGRMangaViewController *mangaVC = [[YGRMangaViewController alloc] init];
    mangaVC.manga = selectedManga;

    [self.navigationController pushViewController:mangaVC animated:YES];
}

@end
