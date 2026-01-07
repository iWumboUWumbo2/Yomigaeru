//
//  YGRExtension.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRExtension : NSObject

@property (nonatomic, strong) NSURL *repo;
@property (nonatomic, strong) NSString *apkName;
@property (nonatomic, strong) NSURL *iconUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pkgName;
@property (nonatomic, strong) NSString *versionName;
@property (nonatomic, assign) NSInteger versionCode;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic, assign) BOOL isNsfw;
@property (nonatomic, assign) BOOL installed;
@property (nonatomic, assign) BOOL hasUpdate;
@property (nonatomic, assign) BOOL obsolete;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)description;

@end
