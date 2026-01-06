//
//  YGRExtensionService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/20.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRExtensionService : NSObject

- (void)fetchAllExtensionsWithCompletion:(void (^)(NSArray *extensions, NSError *error))completion;
- (void)installExtensionWithPackageName:(NSString *)pkgName completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateExtensionWithPackageName:(NSString *)pkgName completion:(void (^)(BOOL success, NSError *error))completion;
- (void)uninstallExtensionWithPackageName:(NSString *)pkgName completion:(void (^)(BOOL success, NSError *error))completion;
- (void)fetchIconWithApkName:(NSString *)apkName completion:(void (^)(UIImage *iconData, NSError *error))completion;

@end
