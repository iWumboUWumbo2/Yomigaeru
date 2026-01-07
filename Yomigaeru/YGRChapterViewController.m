//
//  YGRMangaPageViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRChapterViewController.h"

#import "YGRPageViewController.h"

@interface YGRChapterViewController ()

@property (nonatomic, strong) NSCache *pageControllerCache;

@end

@implementation YGRChapterViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.pageControllerCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title =
        [NSString stringWithFormat:@"Chapter %lu", (unsigned long) self.chapter.chapterNumber];

    // Do any additional setup after loading the view.
    self.dataSource = self;

    YGRPageViewController *pageViewController =
        [self viewControllerForPage:(NSUInteger) self.chapter.lastPageRead];
    [self setViewControllers:@[ pageViewController ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
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

- (YGRPageViewController *)viewControllerForPage:(NSUInteger)pageIndex
{
    if (pageIndex >= self.chapter.pageCount)
    {
        return nil;
    }

    // Use NSCache methods
    YGRPageViewController *cachedPageViewController =
        [self.pageControllerCache objectForKey:@(pageIndex)];
    if (cachedPageViewController != nil)
    {
        return cachedPageViewController;
    }

    YGRPageViewController *pageViewController = [[YGRPageViewController alloc] init];
    pageViewController.mangaId = self.manga.id_;
    pageViewController.chapterIndex = (NSUInteger) self.chapter.chapterNumber;
    pageViewController.pageIndex = pageIndex;

    [self.pageControllerCache setObject:pageViewController forKey:@(pageIndex)];

    return pageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    YGRPageViewController *currentPageViewController = (YGRPageViewController *) viewController;
    return [self viewControllerForPage:currentPageViewController.pageIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    YGRPageViewController *currentPageViewController = (YGRPageViewController *) viewController;
    return [self viewControllerForPage:currentPageViewController.pageIndex + 1];
}

@end
