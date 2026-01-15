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

@interface YGRLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate>

@property (nonatomic, strong) YGRCategoryService *categoryService;
@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) NSMutableArray *mangas;
@property (nonatomic, strong) NSCache *thumbnailCache;

@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;

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
    
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.backgroundColor = [UIColor whiteColor];
    self.gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
    
    [self fetchLibrary];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.refreshSpinner isAnimating]) {
        [self.refreshSpinner stopAnimating];
        self.navigationItem.leftBarButtonItem = self.refreshButton;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Library Loading

- (void)fetchLibrary
{
    __weak typeof(self) weakSelf = self;
    
    [self.categoryService fetchLibraryWithCompletion:^(NSArray *mangas, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.refreshSpinner stopAnimating];
            strongSelf.navigationItem.leftBarButtonItem = strongSelf.refreshButton;
            strongSelf.navigationItem.leftBarButtonItem.enabled = YES;
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
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.refreshSpinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshSpinner];
    [self fetchLibrary];
}

#pragma mark - AQGridView DataSource

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView
{
    return self.mangas.count;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView
{
    return CGSizeMake(120.0, 150.0);
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString *CellIdentifier = @"LibraryCell";
    
    YGRLibraryCell *cell = (YGRLibraryCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        CGRect cellFrame;
        cellFrame.size = [self portraitGridCellSizeForGridView:self.gridView];
        cellFrame.origin.x = 120.0f;
        cellFrame.origin.y = 150.0f;
        
        cell = [[YGRLibraryCell alloc] initWithFrame:cellFrame
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
