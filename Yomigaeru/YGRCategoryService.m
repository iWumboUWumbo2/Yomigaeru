//
//  YGRCategoryService.m
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRCategoryService.h"
#import "YGRNetworkManager.h"
#import "YGRCategory.h"
#import "YGRManga.h"

@implementation YGRCategoryService

- (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *categories, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = @"category";  // No specific endpoint, assume we want all categories
    [jsonClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonArray = (NSArray *)responseObject;
        NSMutableArray *categories = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (NSDictionary *dict in jsonArray) {
            [categories addObject:[[YGRCategory alloc] initWithDictionary:dict]];
        }
        completion(categories, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)fetchMangasWithCategoryId:(NSString *)categoryId
                       completion:(void (^)(NSArray *mangas, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"category/%@", categoryId];
    
    [jsonClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonArray = (NSArray *)responseObject;
        NSMutableArray *mangas = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (NSDictionary *dict in jsonArray) {
            [mangas addObject:[[YGRManga alloc] initWithDictionary:dict]];
        }
        completion(mangas, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)fetchLibraryWithCompletion:(void (^)(NSArray *mangas, NSError *error))completion
{
    [self fetchMangasWithCategoryId:@"0" completion:^(NSArray *mangas, NSError *error) {
        completion(mangas, error);
    }];
}

@end
