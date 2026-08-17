//
//  YGRExtensionService.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/20.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Manages the lifecycle of installable source extensions (fetching the
 *  catalog, installing, updating, and uninstalling) against the server.
 */
@interface YGRExtensionService : NSObject

#pragma mark - Public API

/**
 *  Fetches the full list of extensions known to the server, including
 *  their installed/available/update state.
 *
 *  @param completion Called with the array of `YGRExtension` objects on
 *  success, or `nil` and an error on failure.
 */
- (void)fetchAllExtensionsWithCompletion:(void (^)(NSArray *extensions, NSError *error))completion;

/**
 *  Installs an extension on the server.
 *
 *  @param pkgName The extension's package name.
 *  @param completion Called with `YES` on success, or `NO` and an error on
 *  failure.
 */
- (void)installExtensionWithPackageName:(NSString *)pkgName
                             completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Updates an already-installed extension on the server to its latest
 *  version.
 *
 *  @param pkgName The extension's package name.
 *  @param completion Called with `YES` on success, or `NO` and an error on
 *  failure.
 */
- (void)updateExtensionWithPackageName:(NSString *)pkgName
                            completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Uninstalls an extension from the server.
 *
 *  @param pkgName The extension's package name.
 *  @param completion Called with `YES` on success, or `NO` and an error on
 *  failure.
 */
- (void)uninstallExtensionWithPackageName:(NSString *)pkgName
                               completion:(void (^)(BOOL success, NSError *error))completion;

@end
