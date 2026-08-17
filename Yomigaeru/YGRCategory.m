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
        _id_ = [dictionary[@"id"] description];
        _order = [dictionary[@"order"] integerValue];
        _name = dictionary[@"name"];
        _isDefault = [dictionary[@"default"] boolValue];
        _size = [dictionary[@"size"] integerValue];
        _includeInUpdate = [dictionary[@"includeInUpdate"] integerValue];
        _includeInDownload = [dictionary[@"includeInDownload"] integerValue];
        _meta = dictionary[@"meta"] ?: [NSDictionary dictionary];
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
