//
//  YGRMangaPageViewController.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRChapterViewController.h"

#import "YGRPageViewController.h"

#import "YGRMangaService.h"

@interface YGRChapterViewController ()

@property (nonatomic, strong) YGRMangaService *mangaService;

@property (nonatomic, strong) YGRChapter *chapter;

@end

@implementation YGRChapterViewController

- (id)init
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    if (self)
    {
        self.mangaService = [[YGRMangaService alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chapter = (YGRChapter *)self.chapters[self.chaptersArrayIndex];
    self.title = [NSString stringWithFormat:@"Chapter %u", (NSUInteger) self.chapter.chapterNumber];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(dismissSelf)];

    // Do any additional setup after loading the view.
    self.dataSource = self;
    
    YGRPageViewController *pageViewController = [self viewControllerForPage:(NSUInteger)self.chapter.lastPageRead];
    [self setViewControllers:@[ pageViewController ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    YGRPageViewController *currentPageViewController = (YGRPageViewController *)self.viewControllers.firstObject;
    
    [self.mangaService markLastPageReadForChapterWithMangaId:self.manga.id_
                                                chapterIndex:self.chapter.index
                                                lastPageRead:currentPageViewController.pageIndex
                                                  completion:^(BOOL success, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"%@", error);
                                                          return;
                                                      }
                                                      
                                                      if (!success) {
                                                          NSLog(@"Failed to save last page read");
                                                          return;
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          if ([self.refreshDelegate respondsToSelector:@selector(childDidFinishRefreshing)]) {
                                                              [self.refreshDelegate childDidFinishRefreshing];
                                                          }
                                                      });
                                                  }];
}


- (void)dismissSelf
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)toggleNavigationBar
{
    BOOL hidden = self.navigationController.navigationBarHidden;    
    [self.navigationController setNavigationBarHidden:!hidden animated:YES];
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

- (YGRPageViewController *)viewControllerForPage:(NSInteger)pageIndex
{
    YGRPageViewController *pageViewController = [[YGRPageViewController alloc] init];
    pageViewController.mangaId = self.manga.id_;

    // Go to previous chapter
    if (pageIndex < 0)
    {
        // Check if there is a previous chapter
        if (self.chaptersArrayIndex + 1 >= self.chapters.count) {
            return nil;
        }
        
        self.chaptersArrayIndex++;
        self.chapter = (YGRChapter *)self.chapters[self.chaptersArrayIndex];
        pageIndex = self.chapter.pageCount - 1;
    }
    
    // Go to next chapter
    else if (pageIndex >= self.chapter.pageCount)
    {
        // Check if there is a previous chapter
        if (self.chaptersArrayIndex - 1 < 0) {
            return nil;
        }
        
        self.chaptersArrayIndex--;
        self.chapter = (YGRChapter *)self.chapters[self.chaptersArrayIndex];
        pageIndex = 0;
    }

    pageViewController.chapterIndex = self.chapter.index;
    pageViewController.pageIndex = pageIndex;
    
    return pageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    YGRPageViewController *currentPageViewController = (YGRPageViewController *) viewController;
    return [self viewControllerForPage:(NSInteger)currentPageViewController.pageIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    YGRPageViewController *currentPageViewController = (YGRPageViewController *) viewController;
    return [self viewControllerForPage:currentPageViewController.pageIndex + 1];
}

@end
