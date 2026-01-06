//
//  YGRSource.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRSource : NSObject

@property (nonatomic, strong) NSString * id_;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * lang;
@property (nonatomic, strong) NSURL * iconUrl;
@property (nonatomic, assign) BOOL supportsLatest;
@property (nonatomic, assign) BOOL isConfigurable;
@property (nonatomic, assign) BOOL isNsfw;
@property (nonatomic, strong) NSString * displayName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)description;

@end
