//
//  YGRPageContentViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/06.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Displays a single manga page image in a zoomable scroll view, fetching
 *  the image on demand and reporting load failures via an alert.
 */
@interface YGRPageViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>

#pragma mark - Configuration

/** The id of the manga this page belongs to. */
@property (nonatomic, copy) NSString *mangaId;

/** The 1-based index of the chapter this page belongs to. */
@property (nonatomic, assign) NSInteger chapterIndex;
/** The 0-based index of this page within its chapter. */
@property (nonatomic, assign) NSInteger pageIndex;

@end
