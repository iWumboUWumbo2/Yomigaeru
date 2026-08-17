//
//  YGRCategory.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A library category (a.k.a. tag or shelf) used to group manga together,
 *  as reported by the server.
 */
@interface YGRCategory : NSObject

#pragma mark - Properties

/** The category's server-assigned identifier, stringified. */
@property (nonatomic, copy) NSString *id_;
/** The category's display order relative to other categories. */
@property (nonatomic, assign) NSInteger order;
/** The category's display name. */
@property (nonatomic, copy) NSString *name;
/** Whether this is the server's default/unsorted category. */
@property (nonatomic, assign) BOOL isDefault;
/** The number of manga currently assigned to this category. */
@property (nonatomic, assign) NSInteger size;
/** Whether manga in this category should be included in library updates. */
@property (nonatomic, assign) NSInteger includeInUpdate;
/** Whether manga in this category should be included in downloads. */
@property (nonatomic, assign) NSInteger includeInDownload;
/** Arbitrary server-supplied metadata associated with the category. */
@property (nonatomic, strong) NSDictionary *meta;

#pragma mark - Initialization

/**
 *  Creates a category from a server JSON dictionary.
 *
 *  Maps `id`, `order`, `name`, `default`, `size`, `includeInUpdate`,
 *  `includeInDownload`, and `meta` keys onto the receiver's properties;
 *  `meta` falls back to an empty dictionary when the key is absent.
 *
 *  @param dictionary The decoded JSON dictionary describing the category.
 *
 *  @return An initialized YGRCategory instance.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a human-readable, multi-line dump of the receiver's properties.
 *
 *  @return A debug description string listing every property and its value.
 */
- (NSString *)description;

@end
