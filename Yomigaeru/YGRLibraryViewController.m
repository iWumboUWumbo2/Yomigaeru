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
#import "YGRMangaService.h"
#import "YGRManga.h"
#import "YGRLibraryCell.h"

@interface YGRLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) YGRCategoryService *categoryService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangas;
@property (nonatomic, strong) NSCache *thumbnailCache;

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
    if (self) {
        self.categoryService = [[YGRCategoryService alloc] init];
        self.mangaService = [[YGRMangaService alloc] init];
        self.mangas = [NSMutableArray array];
        self.thumbnailCache = [[NSCache alloc] init];
        self.selectedIndex = NSNotFound;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Library";
    
    // Refresh button & spinner
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                       target:self
                                                                       action:@selector(refreshLibrary)];
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Edit" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.backgroundColor = [UIColor whiteColor];
    self.gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    self.gridView.bounces = YES;
    self.gridView.alwaysBounceVertical = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.gridView addGestureRecognizer:longPress];
    
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [self.actionSheet showFromRect:[self.gridView rectForItemAtIndex:index] inView:self.view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [self.actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    YGRManga *selectedManga = [self.mangas objectAtIndex:self.selectedIndex];
    
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        __weak typeof(self) weakSelf = self;
        
        [self.mangaService deleteFromLibraryWithMangaId:selectedManga.id_ completion:^(BOOL success, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error)
            {
                NSLog(@"%@", error);
                return;
            }
            
            if (!success)
            {
                NSLog(@"Failed to delete manga at index (%d)", strongSelf.selectedIndex);
            }
            
            [strongSelf.mangas removeObjectAtIndex:strongSelf.selectedIndex];
            [strongSelf.gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:strongSelf.selectedIndex] withAnimation:AQGridViewItemAnimationNone];
        }];
    }
}

- (void)enableSpinner
{
    if (![ self.refreshSpinner isAnimating])
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self.refreshSpinner startAnimating];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshSpinner];
    }
}

- (void)disableSpinner
{
    if ([self.refreshSpinner isAnimating]) {
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
        if (!strongSelf) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf disableSpinner];
        });
        
        if (error) {
            NSLog(@"Error fetching library: %@", error);
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
    
    YGRLibraryCell *cell = (YGRLibraryCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        CGSize cellSize = [self portraitGridCellSizeForGridView:self.gridView];
        
        cell = [[YGRLibraryCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)
                                     reuseIdentifier:CellIdentifier];
        cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }
    
    YGRManga *manga = [self.mangas objectAtIndex:index];
    cell.title = manga.title;
    
    UIImage *cachedThumbnail = [self.thumbnailCache objectForKey:manga.id_];
    if (cachedThumbnail) {
        cell.image = cachedThumbnail;
    } else {
        cell.image = [UIImage imageNamed:@"placeholder"];
        
        __weak typeof(cell) weakCell = cell;
        __weak typeof(self) weakSelf = self;
        [self.mangaService fetchThumbnailWithMangaId:manga.id_ completion:^(UIImage *thumbnailImage, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || error || !thumbnailImage) return;
            
            [strongSelf.thumbnailCache setObject:thumbnailImage forKey:manga.id_];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Ensure the cell still represents the same manga
                if ([weakCell.title isEqualToString:manga.title]) {
                    weakCell.image = thumbnailImage;
                }
            });
        }];
    }
    
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
