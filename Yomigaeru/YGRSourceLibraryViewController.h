//
//  YGRSourceLibraryViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/16.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSource.h"
#import <AQGridView/AQGridView.h>
#import <UIKit/UIKit.h>

@interface YGRSourceLibraryViewController
    : UIViewController <AQGridViewDataSource, AQGridViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) YGRSource *source;

- (id)init;

@end
