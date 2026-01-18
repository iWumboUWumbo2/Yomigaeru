//
//  YGRSourceLibraryViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/16.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRSource.h"
#import <AQGridView/AQGridView.h>

@interface YGRSourceLibraryViewController : UIViewController <AQGridViewDataSource, AQGridViewDelegate>

@property (nonatomic, strong) YGRSource *source;

- (id)init;

@end
