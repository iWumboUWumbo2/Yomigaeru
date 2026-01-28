//
//  YGRBrowseSearchBarDelegateProxy.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRBrowseSearchBarDelegateProxy : NSObject <UISearchBarDelegate>

@property (nonatomic, weak) id<UISearchBarDelegate> stateHandler;
@property (nonatomic, weak) id<UISearchBarDelegate> searchHandler;

@end
