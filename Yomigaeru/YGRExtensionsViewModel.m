//
//  YGRExtensionsViewModel.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRExtensionsViewModel.h"
#import "YGRExtensionService.h"

NSString *const kExtensionUpdatesPendingKey = @"Updates pending";
NSString *const kExtensionInstalledKey = @"Installed";

@interface YGRExtensionsViewModel ()

@property (nonatomic, strong) YGRExtensionService *service;

// canonical data
@property (nonatomic, strong) NSArray *allSections;
@property (nonatomic, strong) NSDictionary *allExtensionsBySection;

// derived (search)
@property (nonatomic, strong) NSArray *visibleSections;
@property (nonatomic, strong) NSDictionary *visibleExtensionsBySection;

@property (nonatomic, copy) NSString *searchTerm;

@end

@implementation YGRExtensionsViewModel

- (instancetype)init {
    if (self = [super init]) {
        _service = [[YGRExtensionService alloc] init];
    }
    return self;
}

#pragma mark - Public API

- (NSArray *)sections {
    return self.visibleSections ?: self.allSections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sections[section];
    return [self.visibleExtensionsBySection[key] count];
}

- (YGRExtension *)extensionAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.sections[indexPath.section];
    return self.visibleExtensionsBySection[key][indexPath.row];
}

#pragma mark - Fetching

- (void)refreshWithCompletion:(void (^)(NSError *))completion {
    [self.service fetchAllExtensionsWithCompletion:^(NSArray *extensions, NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        [self buildSectionsFromExtensions:extensions];
        
        if (self.searchTerm.length > 0) {
            [self applySearch:self.searchTerm];
        } else {
            self.visibleSections = self.allSections;
            self.visibleExtensionsBySection = self.allExtensionsBySection;
        }
        
        completion(nil);
    }];
}

#pragma mark - Search

- (void)searchWithTerm:(NSString *)term {
    self.searchTerm = term;
    [self applySearch:term];
}

- (void)clearSearch {
    self.searchTerm = nil;
    self.visibleSections = self.allSections;
    self.visibleExtensionsBySection = self.allExtensionsBySection;
}

- (void)applySearch:(NSString *)term {
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *lower = term.lowercaseString;
    
    for (NSString *section in self.allSections) {
        NSArray *extensions = self.allExtensionsBySection[section];
        NSPredicate *p =
        [NSPredicate predicateWithBlock:^BOOL(YGRExtension *ext, NSDictionary *_) {
            return [ext.lowerName hasPrefix:lower];
        }];
        
        NSArray *filtered = [extensions filteredArrayUsingPredicate:p];
        if (filtered.count > 0) {
            sections[sections.count] = section;
            dict[section] = filtered;
        }
    }
    
    self.visibleSections = sections;
    self.visibleExtensionsBySection = dict;
}

#pragma mark - Actions

- (void)installExtension:(YGRExtension *)extension completion:(void (^)(NSError *))completion {
    [self.service installExtensionWithPackageName:extension.pkgName
                                       completion:^(BOOL success, NSError *error) {
                                           completion(error);
                                       }];
}

- (void)removeExtension:(YGRExtension *)extension completion:(void (^)(NSError *))completion {
    [self.service uninstallExtensionWithPackageName:extension.pkgName
                                         completion:^(BOOL success, NSError *error) {
                                             completion(error);
                                         }];
}

- (void)updateExtension:(YGRExtension *)extension completion:(void (^)(NSError *))completion {
    [self.service updateExtensionWithPackageName:extension.pkgName
                                      completion:^(BOOL success, NSError *error) {
                                          completion(error);
                                      }];
}

#pragma mark - Private

- (void)buildSectionsFromExtensions:(NSArray *)extensions
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableDictionary *bySection = [NSMutableDictionary dictionary];
    
    NSMutableArray *updatesPending = [NSMutableArray array];
    NSMutableArray *installed = [NSMutableArray array];
    
    for (YGRExtension *extension in extensions)
    {
        if (extension.hasUpdate)
        {
            [updatesPending addObject:extension];
        }
        else if (extension.installed)
        {
            [installed addObject:extension];
        }
        else
        {
            NSString *lang = extension.lang;
            NSMutableArray *array = bySection[lang];
            
            if (!array)
            {
                array = [NSMutableArray array];
                bySection[lang] = array;
                [sections addObject:lang];
            }
            
            [array addObject:extension];
        }
    }
    
    // Insert special sections in correct order
    if (updatesPending.count > 0)
    {
        bySection[kExtensionUpdatesPendingKey] = updatesPending;
        [sections insertObject:kExtensionUpdatesPendingKey atIndex:0];
    }
    
    if (installed.count > 0)
    {
        NSUInteger index = (updatesPending.count > 0) ? 1 : 0;
        bySection[kExtensionInstalledKey] = installed;
        [sections insertObject:kExtensionInstalledKey atIndex:index];
    }
    
    // Freeze state (immutable outward)
    self.allSections = [sections copy];
    self.allExtensionsBySection = [bySection copy];
}

@end
