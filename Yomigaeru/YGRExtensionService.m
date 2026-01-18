//
//  YGRExtensionService.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/20.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRExtensionService.h"
#import "YGRExtension.h"
#import "YGRNetworkManager.h"

@implementation YGRExtensionService

- (void)performExtensionAction:(NSString *)action
                   packageName:(NSString *)pkgName
                    completion:(void (^)(BOOL success, NSError *error))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString stringWithFormat:@"extension/%@/%@", action, pkgName];

    [httpClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completion(YES, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO, error);
        }];
}

- (void)fetchAllExtensionsWithCompletion:(void (^)(NSArray *extensions, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    [jsonClient getPath:@"extension/list"
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *jsonArray = (NSArray *) responseObject;
            NSMutableArray *extensions = [NSMutableArray arrayWithCapacity:jsonArray.count];
            for (NSDictionary *dict in jsonArray)
            {
                [extensions addObject:[[YGRExtension alloc] initWithDictionary:dict]];
            }
            completion(extensions, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

- (void)installExtensionWithPackageName:(NSString *)pkgName
                             completion:(void (^)(BOOL, NSError *))completion
{
    [self performExtensionAction:@"install" packageName:pkgName completion:completion];
}

- (void)updateExtensionWithPackageName:(NSString *)pkgName
                            completion:(void (^)(BOOL, NSError *))completion
{
    [self performExtensionAction:@"update" packageName:pkgName completion:completion];
}

- (void)uninstallExtensionWithPackageName:(NSString *)pkgName
                               completion:(void (^)(BOOL, NSError *))completion
{
    [self performExtensionAction:@"uninstall" packageName:pkgName completion:completion];
}

- (void)fetchIconWithApkName:(NSString *)apkName
                  completion:(void (^)(UIImage *, NSError *))completion
{
    AFHTTPClient *httpClient = [[YGRNetworkManager sharedManager] httpClientInstance];
    NSString *path = [NSString stringWithFormat:@"extension/icon/%@", apkName];

    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:path parameters:nil];

    AFImageRequestOperation *imageOperation =
        [AFImageRequestOperation imageRequestOperationWithRequest:request
            imageProcessingBlock:nil
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                completion(image, nil);
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                completion(nil, error);
            }];

    // Enqueue the operation
    [httpClient enqueueHTTPRequestOperation:imageOperation];
}

@end
