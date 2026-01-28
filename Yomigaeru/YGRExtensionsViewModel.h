//
//  YGRExtensionsViewModel.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGRExtension.h"

extern NSString *const kExtensionUpdatesPendingKey;
extern NSString *const kExtensionInstalledKey;

@interface YGRExtensionsViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray *sections;

- (void)refreshWithCompletion:(void (^)(NSError *error))completion;

// Table helpers
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (YGRExtension *)extensionAtIndexPath:(NSIndexPath *)indexPath;

// Search
- (void)searchWithTerm:(NSString *)term;
- (void)clearSearch;

// Actions
- (void)installExtension:(YGRExtension *)extension completion:(void (^)(NSError *error))completion;
- (void)removeExtension:(YGRExtension *)extension completion:(void (^)(NSError *error))completion;
- (void)updateExtension:(YGRExtension *)extension completion:(void (^)(NSError *error))completion;

@end
