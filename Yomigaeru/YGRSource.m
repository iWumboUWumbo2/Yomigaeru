//
//  YGRSource.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRSource.h"
#import "YGRSettingsManager.h"

@implementation YGRSource

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _id_ = dictionary[@"id"];
        _name = dictionary[@"name"];
        _lowerName = [_name lowercaseString];
        _lang = dictionary[@"lang"];
        _iconUrl =
            [[YGRSettingsManager sharedInstance] URLForPath:dictionary[@"iconUrl"]];
        _supportsLatest = [dictionary[@"supportsLatest"] boolValue];
        _isConfigurable = [dictionary[@"isConfigurable"] boolValue];
        _isNsfw = [dictionary[@"isNsfw"] boolValue];
        _displayName = dictionary[@"displayName"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> {\n"
                                       "  id_ = %@;\n"
                                       "  name = %@;\n"
                                       "  lang = %@;\n"
                                       "  iconUrl = %@;\n"
                                       "  supportsLatest = %@;\n"
                                       "  isConfigurable = %@;\n"
                                       "  isNsfw = %@;\n"
                                       "  displayName = %@;\n"
                                       "}",
                                      NSStringFromClass([self class]), self, self.id_, self.name,
                                      self.lang, self.iconUrl, self.supportsLatest ? @"YES" : @"NO",
                                      self.isConfigurable ? @"YES" : @"NO",
                                      self.isNsfw ? @"YES" : @"NO", self.displayName];
}

@end
