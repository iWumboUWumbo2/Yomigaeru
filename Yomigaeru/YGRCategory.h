//
//  YGRCategory.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRCategory : NSObject

@property (nonatomic, copy) NSString *id_;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSInteger includeInUpdate;
@property (nonatomic, assign) NSInteger includeInDownload;
@property (nonatomic, strong) NSDictionary *meta;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)description;

@end
