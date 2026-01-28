//
//  YGRSourcesViewModel.m
//  Yomigaeru
//
//  Created by John Connery on 2026/01/27.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRSourcesViewModel.h"
#import "YGRSourceService.h"
#import "YGRSource.h"

@interface YGRSourcesViewModel ()

@property (nonatomic, strong) YGRSourceService *service;

// canonical
@property (nonatomic, copy) NSArray *allSections;
@property (nonatomic, copy) NSDictionary *allSourcesBySection;

// derived (search)
@property (nonatomic, copy) NSArray *visibleSections;
@property (nonatomic, copy) NSDictionary *visibleSourcesBySection;

@property (nonatomic, copy) NSString *searchTerm;

@end

@implementation YGRSourcesViewModel

- (instancetype)init
{
    if (self = [super init]) {
        _service = [[YGRSourceService alloc] init];
    }
    return self;
}

#pragma mark - Public API

- (NSArray *)sections
{
    return self.visibleSections ?: self.allSections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.sections[section];
    return [self.visibleSourcesBySection[key] count];
}

- (YGRSource *)sourceAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.sections[indexPath.section];
    return self.visibleSourcesBySection[key][indexPath.row];
}

#pragma mark - Fetching

- (void)refreshWithCompletion:(void (^)(NSError *))completion
{
    [self.service fetchAllSourcesWithCompletion:^(NSArray *sources, NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        [self buildSectionsFromSources:sources];
        
        if (self.searchTerm.length > 0) {
            [self applySearch:self.searchTerm];
        } else {
            self.visibleSections = self.allSections;
            self.visibleSourcesBySection = self.allSourcesBySection;
        }
        
        completion(nil);
    }];
}

#pragma mark - Search

- (void)searchWithTerm:(NSString *)term
{
    self.searchTerm = term;
    [self applySearch:term];
}

- (void)clearSearch
{
    self.searchTerm = nil;
    self.visibleSections = self.allSections;
    self.visibleSourcesBySection = self.allSourcesBySection;
}

- (void)applySearch:(NSString *)term
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *lower = term.lowercaseString;
    
    for (NSString *section in self.allSections) {
        NSArray *sources = self.allSourcesBySection[section];
        
        NSPredicate *predicate =
        [NSPredicate predicateWithBlock:^BOOL(YGRSource *source, NSDictionary *_) {
            return [source.lowerName hasPrefix:lower];
        }];
        
        NSArray *filtered = [sources filteredArrayUsingPredicate:predicate];
        if (filtered.count > 0) {
            [sections addObject:section];
            dict[section] = filtered;
        }
    }
    
    self.visibleSections = sections;
    self.visibleSourcesBySection = dict;
}

#pragma mark - Section building

- (void)buildSectionsFromSources:(NSArray *)sources
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableDictionary *bySection = [NSMutableDictionary dictionary];
    
    for (YGRSource *source in sources) {
        NSString *lang = source.lang;
        NSMutableArray *array = bySection[lang];
        
        if (!array) {
            array = [NSMutableArray array];
            bySection[lang] = array;
            [sections addObject:lang];
        }
        
        [array addObject:source];
    }
    
    self.allSections = [sections copy];
    self.allSourcesBySection = [bySection copy];
}

@end

