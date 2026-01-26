//
//  YGRPageContentViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRPageViewController.h"

#import "YGRImageService.h"
#import "YGRMangaService.h"

@interface YGRPageViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation YGRPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;

    [self.view addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    [self.scrollView addSubview:self.imageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;

    CGSize imageSize = image.size;
    CGSize scrollSize = self.scrollView.bounds.size;

    // Scale so image width matches screen width
    CGFloat scale = scrollSize.width / imageSize.width;

    CGFloat width = scrollSize.width;
    CGFloat height = imageSize.height * scale;

    self.imageView.frame = CGRectMake(0, 0, width, height);
    self.scrollView.contentSize = CGSizeMake(width, height);

    // Reset zoom
    self.scrollView.zoomScale = 1.0;

    // Center vertically if image is shorter than screen
    if (height < scrollSize.height)
    {
        self.imageView.center = CGPointMake(scrollSize.width / 2, scrollSize.height / 2);
    }
}

- (void)loadPageImage
{
    __weak typeof(self) weakSelf = self;

    [[YGRImageService sharedService] fetchPageWithMangaId:self.mangaId
                                             chapterIndex:self.chapterIndex
                                                pageIndex:self.pageIndex
                                               completion:^(UIImage *pageData, NSError *error) {
                                                   __strong typeof(weakSelf) strongSelf = weakSelf;

                                                   if (error)
                                                   {
                                                       NSLog(@"%@", error);
                                                       return;
                                                   }

                                                   if (!pageData)
                                                   {
                                                       NSLog(@"Failed to load image");
                                                       return;
                                                   }

                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [strongSelf setImage:pageData];
                                                   });
                                               }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.zoomScale = 1.0;
    [self loadPageImage];
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
