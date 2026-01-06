//
//  TestViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/23.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRAPITestViewController.h"
#import "YGRImageUtility.h"

#import "YGRCategoryService.h"
#import "YGRExtensionService.h"
#import "YGRMangaService.h"
#import "YGRSourceService.h"

#define LOG(data)                       \
    do { if (error)                     \
    {                                   \
        NSLog(@"%@", error);            \
        return;                         \
    }                                   \
                                        \
    NSLog(@"%@", data); } while (0)

#define LOG_IMAGE(data)                                 \
    do { if (data)                                      \
    {                                                   \
        dispatch_async(dispatch_get_main_queue(), ^{    \
            imageView.image = data;                     \
        });                                             \
    }                                                   \
    else                                                \
    {                                                   \
        NSLog(@"Failed to load image");                 \
    } } while (0)

#define LOG_SUCCESS \
    do { NSLog(@"%@", success ? @"YES" : @"NO"); } while (0)

@interface YGRAPITestViewController ()

@property (nonatomic, strong) YGRCategoryService *categoryService;
@property (nonatomic, strong) YGRExtensionService *extensionService;
@property (nonatomic, strong) YGRMangaService *mangaService;
@property (nonatomic, strong) YGRSourceService *sourceService;

- (void)initServices;

- (void)testCategoryService;
- (void)testExtensionService;
- (void)testMangaService;
- (void)testSourceService;
- (void)testWebP;

@end

@implementation YGRAPITestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initServices
{
    self.categoryService = [[YGRCategoryService alloc] init];
    self.extensionService = [[YGRExtensionService alloc] init];
    self.mangaService = [[YGRMangaService alloc] init];
    self.sourceService = [[YGRSourceService alloc] init];
}

- (void)testCategoryService
{
    [self.categoryService fetchAllCategoriesWithCompletion:^(NSArray *categories, NSError *error) {
        LOG(categories);
    }];
    
    [self.categoryService fetchMangasWithCategoryId:@"0" completion:^(NSArray *mangas, NSError *error) {
        LOG(mangas);
    }];
    
    [self.categoryService fetchLibraryWithCompletion:^(NSArray *mangas, NSError *error) {
        LOG(mangas);
    }];
}

- (void)testExtensionService
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    [self.extensionService fetchAllExtensionsWithCompletion:^(NSArray *extensions, NSError *error) {
        LOG(extensions);
    }];
    
    NSString *pkgName = @"eu.kanade.tachiyomi.extension.all.ninemanga";
    
    [self.extensionService installExtensionWithPackageName:pkgName completion:^(BOOL success, NSError *error) {
        LOG_SUCCESS;
    }];
    
    [self.extensionService updateExtensionWithPackageName:pkgName completion:^(BOOL success, NSError *error) {
        LOG_SUCCESS;
    }];
    
    [self.extensionService uninstallExtensionWithPackageName:pkgName completion:^(BOOL success, NSError *error) {
        LOG_SUCCESS;
    }];

    [self.extensionService fetchIconWithApkName:@"tachiyomi-all.baobua-v1.4.1.apk" completion:^(UIImage *iconData, NSError *error) {
        LOG_IMAGE(iconData);
    }];

    
}

- (void)testMangaService
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    NSString *mangaId = @"55";
    
    [self.mangaService fetchMangaWithId:mangaId completion:^(YGRManga *manga, NSError *error) {
        LOG(manga);
    }];
    
    [self.mangaService fetchFullMangaWithId:mangaId completion:^(YGRManga *manga, NSError *error) {
        LOG(manga);
    }];
    
    [self.mangaService fetchThumbnailWithMangaId:mangaId completion:^(UIImage *thumbnailImage, NSError *error) {
        LOG_IMAGE(thumbnailImage);
    }];
    
    [self.mangaService addToLibraryWithMangaId:mangaId completion:^(BOOL success, NSError *error) {
        LOG_SUCCESS;
    }];
    
    [self.mangaService deleteFromLibraryWithMangaId:mangaId completion:^(BOOL success, NSError *error) {
        LOG_SUCCESS;
    }];
    
    [self.mangaService fetchChapterWithMangaId:mangaId chapterIndex:13 completion:^(YGRChapter *chapter, NSError *error) {
        LOG(chapter);
    }];
    
    [self.mangaService fetchChaptersWithMangaId:mangaId completion:^(NSArray *chapters, NSError *error) {
        LOG(chapters);
    }];
    
    [self.mangaService fetchPageWithMangaId:mangaId chapterIndex:13 pageIndex:1 completion:^(UIImage *pageData, NSError *error) {
        LOG_IMAGE(pageData);
    }];
}

- (void)testSourceService
{    
    [self.sourceService fetchAllSourcesWithCompletion:^(NSArray *sources, NSError *error) {
        LOG(sources);
    }];
    
    NSString *sourceId = @"626267698662819838";
    
    [self.sourceService fetchSourceWithId:sourceId completion:^(YGRSource *source, NSError *error) {
        LOG(source);
    }];
    
    [self.sourceService fetchPopularMangaFromSourceId:sourceId pageNum:1 completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
        LOG(mangaList);
    }];
    
    [self.sourceService fetchLatestMangaFromSourceId:sourceId pageNum:1 completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
        LOG(mangaList);
    }];
    
    [self.sourceService searchMangaInSourceId:sourceId searchTerm:@"Healer" pageNum:1 completion:^(NSArray *mangaList, BOOL hasNextPage, NSError *error) {
        LOG(mangaList);
    }];
}

- (void)testWebP {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create an image view that fills the screen
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"webp"];
        if (!imagePath) {
            NSLog(@"Image not found in bundle!");
            return;
        }
        
        // Load the image as NSData
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        if (!imageData) {
            NSLog(@"Failed to load image data!");
            return;
        }
        
        // Create UIImage from NSData
        NSError *error = nil;
        UIImage *image = [YGRImageUtility imageWithWebPData:imageData scale:1.0 fittingSize:CGSizeZero error:&error];
        if (!image) {
            NSLog(@"Failed to create UIImage from data!");
            return;
        }
        
        imageView.image = image;
        
        // Scale the image to fit while keeping aspect ratio
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Add the image view to the main view
        [self.view addSubview:imageView];
    });
}

- (UIButton *)createTestButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.clipsToBounds = YES;
    return button;
}

- (void)setupTestButtons
{
    // Create buttons for each service
    UIButton *categoryButton = [self createTestButtonWithTitle:@"Test Category Service" action:@selector(testCategoryService)];
    UIButton *extensionButton = [self createTestButtonWithTitle:@"Test Extension Service" action:@selector(testExtensionService)];
    UIButton *mangaButton = [self createTestButtonWithTitle:@"Test Manga Service" action:@selector(testMangaService)];
    UIButton *sourceButton = [self createTestButtonWithTitle:@"Test Source Service" action:@selector(testSourceService)];
    UIButton *webPButton = [self createTestButtonWithTitle:@"Test WebP" action:@selector(testWebP)];
    
    // Layout buttons vertically
    CGFloat buttonWidth = self.view.bounds.size.width - 40;
    CGFloat buttonHeight = 50;
    CGFloat yOffset = 100;  // Start y position for the buttons
    
    for (UIButton *button in @[categoryButton, extensionButton, mangaButton, sourceButton, webPButton]) {
        button.frame = CGRectMake(20, yOffset, buttonWidth, buttonHeight);
        [self.view addSubview:button];
        yOffset += buttonHeight + 20;  // Move the next button below with a little padding
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initServices];
    
    [self setupTestButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
