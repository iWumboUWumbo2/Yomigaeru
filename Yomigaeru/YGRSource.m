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
        _id_ = [dictionary objectForKey:@"id"];
        _name = [dictionary objectForKey:@"name"];
        _lang = [dictionary objectForKey:@"lang"];
        _iconUrl = [[YGRSettingsManager sharedInstance] URLForPath:[dictionary objectForKey:@"iconUrl"]];
        _supportsLatest = [[dictionary objectForKey:@"supportsLatest"] boolValue];
        _isConfigurable = [[dictionary objectForKey:@"isConfigurable"] boolValue];
        _isNsfw = [[dictionary objectForKey:@"isNsfw"] boolValue];
        _displayName = [dictionary objectForKey:@"displayName"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<%@: %p> {\n"
            "  id_ = %@;\n"
            "  name = %@;\n"
            "  lang = %@;\n"
            "  iconUrl = %@;\n"
            "  supportsLatest = %@;\n"
            "  isConfigurable = %@;\n"
            "  isNsfw = %@;\n"
            "  displayName = %@;\n"
            "}",
            NSStringFromClass([self class]), self,
            self.id_,
            self.name,
            self.lang,
            self.iconUrl,
            self.supportsLatest ? @"YES" : @"NO",
            self.isConfigurable ? @"YES" : @"NO",
            self.isNsfw ? @"YES" : @"NO",
            self.displayName];
}

@end
