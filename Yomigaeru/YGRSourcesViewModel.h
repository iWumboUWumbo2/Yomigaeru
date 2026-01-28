//
//  YGRSourcesViewModel.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRSource.h"

@interface YGRSourcesViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray *sections;

- (void)refreshWithCompletion:(void (^)(NSError *error))completion;

// Table helpers
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (YGRSource *)sourceAtIndexPath:(NSIndexPath *)indexPath;

// Search
- (void)searchWithTerm:(NSString *)term;
- (void)clearSearch;

@end
