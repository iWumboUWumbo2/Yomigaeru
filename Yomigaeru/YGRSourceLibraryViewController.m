//
//  YGRSourceLibraryViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/16.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourceLibraryViewController.h"
#import "YGRMangaViewController.h"

#import "YGRManga.h"
#import "YGRSourceService.h"
#import "YGRMangaService.h"

#import "YGRLibraryCell.h"
#import "YGRImageService.h"

@interface YGRSourceLibraryViewController ()

@property (nonatomic, strong) UISegmentedControl *mangaListSegmentedControl;
@property (nonatomic, strong) AQGridView *libraryGridView;

@property (nonatomic, strong) YGRSourceService *sourceService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangas;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL isLoadingPage;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, assign) CGSize portraitCellSize;

@end

@implementation YGRSourceLibraryViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.sourceService = [[YGRSourceService alloc] init];
        self.mangaService = [[YGRMangaService alloc] init];
        self.mangas = [NSMutableArray array];
        self.currentPage = 1;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        int columnCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 4 : 2;
        CGFloat cellWidth = screenWidth / columnCount;
        
        self.portraitCellSize = CGSizeMake(cellWidth, cellWidth * 1.25);

    }
    return self;
}

- (void)configureViewControllerSegmentedControl
{
    self.mangaListSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Popular", @"Latest" ]];
    self.mangaListSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.mangaListSegmentedControl addTarget:self action:@selector(mangaListDidChange:) forControlEvents:UIControlEventValueChanged];
    self.mangaListSegmentedControl.selectedSegmentIndex = 0;
    
    CGFloat padding = 8.0f;
    CGFloat height  = 32.0f;
    
    self.mangaListSegmentedControl.frame = CGRectMake(padding, padding, self.view.bounds.size.width - (padding * 2), height);
    
    self.mangaListSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.mangaListSegmentedControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.source.displayName;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureViewControllerSegmentedControl];
    
    CGFloat top = CGRectGetMaxY(self.mangaListSegmentedControl.frame) + 8.0f;
    
    CGRect contentViewFrame = CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top);
    
    self.libraryGridView = [[AQGridView alloc] initWithFrame:contentViewFrame];
    self.libraryGridView.dataSource = self;
    self.libraryGridView.delegate = self;
    self.libraryGridView.backgroundColor = [UIColor whiteColor];
    self.libraryGridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    self.libraryGridView.bounces = YES;
    self.libraryGridView.alwaysBounceVertical = YES;
    self.libraryGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.libraryGridView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.libraryGridView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self fetchMangaList:self.mangaListSegmentedControl];
}

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
    
    YGRManga *selectedManga = self.mangas[index];
    
    __weak typeof(self) weakSelf = self;
    if (!selectedManga.inLibrary)
    {
        [self.mangaService addToLibraryWithMangaId:selectedManga.id_ completion:^(BOOL success, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error)
            {
                NSLog(@"%@", error);
                return;
            }
            
            if (!success)
            {
                NSLog(@"Failed to add manga to library");
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                selectedManga.inLibrary = YES;
                [strongSelf.libraryGridView reloadItemsAtIndices:[NSIndexSet indexSetWithIndex:index] withAnimation:AQGridViewItemAnimationFade];
            });
        }];
    }
    else
    {
        [self.mangaService deleteFromLibraryWithMangaId:selectedManga.id_ completion:^(BOOL success, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error)
            {
                NSLog(@"%@", error);
                return;
            }
            
            if (!success)
            {
                NSLog(@"Failed to delete manga from library");
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                selectedManga.inLibrary = NO;
                [strongSelf.libraryGridView reloadItemsAtIndices:[NSIndexSet indexSetWithIndex:index] withAnimation:AQGridViewItemAnimationFade];
            });
        }];
    }
}

- (void)fetchPopularManga
{
    __weak typeof(self) weakSelf = self;
    
    [self.sourceService fetchPopularMangaFromSourceId:self.source.id_ pageNum:self.currentPage completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        
        NSLog(@"ABC");
        
        [strongSelf.mangas addObjectsFromArray:mangaList];
        strongSelf.hasNextPage = hasNextPage;
        strongSelf.isLoadingPage = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.libraryGridView reloadData];
        });
    }];
}

- (void)fetchLatestManga
{
    __weak typeof(self) weakSelf = self;
    
    [self.sourceService fetchLatestMangaFromSourceId:self.source.id_ pageNum:self.currentPage completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        
        [strongSelf.mangas addObjectsFromArray:mangaList];
        strongSelf.hasNextPage = hasNextPage;
        strongSelf.isLoadingPage = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.libraryGridView reloadData];
        });
    }];
}

- (void)fetchMangaList:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: // Popular
            [self fetchPopularManga];
            break;
            
        case 1: // Latest
            [self fetchLatestManga];
        default:
            break;
    }
}

- (void)mangaListDidChange:(UISegmentedControl *)sender
{
    self.currentPage = 1;
    [self.mangas removeAllObjects];
    
    [self.libraryGridView setContentOffset:CGPointZero animated:NO];
    [self fetchMangaList:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ScrolView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // How close to the bottom before loading more
    CGFloat preloadMargin = self.portraitCellSize.height * 2.0f;
    
    if (scrollView.contentOffset.y + scrollView.bounds.size.height >=
        scrollView.contentSize.height - preloadMargin) {
        [self loadNextPageIfNeeded];
    }
}

- (void)loadNextPageIfNeeded
{
    if (!self.hasNextPage)
    {
        return;
    }
    
    if (self.isLoadingPage)
    {
        return;
    }
    
    self.isLoadingPage = YES;
    self.currentPage++;
    
    [self fetchMangaList:self.mangaListSegmentedControl];
}

#pragma mark - AQGridView DataSource

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView
{
    return !self.mangas ? 0 : self.mangas.count;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView
{
    return self.portraitCellSize;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString *CellIdentifier = @"LibraryCell";
    
    YGRLibraryCell *cell = (YGRLibraryCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        CGSize cellSize = [self portraitGridCellSizeForGridView:self.libraryGridView];
        
        cell = [[YGRLibraryCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)
                                     reuseIdentifier:CellIdentifier];
        cell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }
    
    YGRManga *manga = [self.mangas objectAtIndex:index];
    cell.title = manga.title;
    
    if (manga.inLibrary) {
        [cell showBorder];
    } else {
        [cell hideBorder];
    }
    
    cell.image = [UIImage imageNamed:@"placeholder"];
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    [[YGRImageService sharedService] fetchThumbnailWithMangaId:manga.id_ completion:^(UIImage *thumbnailImage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || error || !thumbnailImage) return;
                
        dispatch_async(dispatch_get_main_queue(), ^{
            // Ensure the cell still represents the same manga
            if ([weakCell.title isEqualToString:manga.title]) {
                weakCell.image = thumbnailImage;
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
