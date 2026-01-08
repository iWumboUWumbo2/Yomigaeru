//
//  YGRCategory.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRCategory.h"

@implementation YGRCategory

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _id_ = [[dictionary objectForKey:@"id"] description];
        _order = [[dictionary objectForKey:@"order"] integerValue];
        _name = [dictionary objectForKey:@"name"];
        _isDefault = [[dictionary objectForKey:@"default"] boolValue];
        _size = [[dictionary objectForKey:@"size"] integerValue];
        _includeInUpdate = [[dictionary objectForKey:@"includeInUpdate"] integerValue];
        _includeInDownload = [[dictionary objectForKey:@"includeInDownload"] integerValue];        
        _meta = [dictionary objectForKey:@"meta"] ?: [NSDictionary dictionary];        
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> {\n"
                                       "  id_ = %@;\n"
                                       "  order = %ld;\n"
                                       "  name = %@;\n"
                                       "  isDefault = %@;\n"
                                       "  size = %ld;\n"
                                       "  includeInUpdate = %ld;\n"
                                       "  includeInDownload = %ld;\n"
                                       "  meta = %@;\n"
                                       "}",
                                      NSStringFromClass([self class]), self, self.id_,
                                      (long) self.order, self.name, self.isDefault ? @"YES" : @"NO",
                                      (long) self.size, (long) self.includeInUpdate,
                                      (long) self.includeInDownload, self.meta];
}

@end
