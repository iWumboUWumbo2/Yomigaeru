//
//  YGRExtension.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRExtension.h"
#import "YGRSettingsManager.h"

@implementation YGRExtension

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _repo = [NSURL URLWithString:dictionary[@"repo"]];
        _apkName = dictionary[@"apkName"];
        _iconUrl =
            [[YGRSettingsManager sharedInstance] URLForPath:dictionary[@"iconUrl"]];
        _name = dictionary[@"name"];
        _lowerName = [_name lowercaseString];
        _pkgName = dictionary[@"pkgName"];
        _versionName = dictionary[@"versionName"];
        _versionCode = [dictionary[@"versionCode"] integerValue];
        _lang = dictionary[@"lang"];
        _isNsfw = [dictionary[@"isNsfw"] boolValue];
        _installed = [dictionary[@"installed"] boolValue];
        _hasUpdate = [dictionary[@"hasUpdate"] boolValue];
        _obsolete = [dictionary[@"obsolete"] boolValue];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return
        [NSString stringWithFormat:@"<%@: %p> {\n"
                                    "  repo = %@;\n"
                                    "  apkName = %@;\n"
                                    "  iconUrl = %@;\n"
                                    "  name = %@;\n"
                                    "  pkgName = %@;\n"
                                    "  versionName = %@;\n"
                                    "  versionCode = %ld;\n"
                                    "  lang = %@;\n"
                                    "  isNsfw = %@;\n"
                                    "  installed = %@;\n"
                                    "  hasUpdate = %@;\n"
                                    "  obsolete = %@;\n"
                                    "}",
                                   NSStringFromClass([self class]), self, self.repo, self.apkName,
                                   self.iconUrl, self.name, self.pkgName, self.versionName,
                                   (long) self.versionCode, self.lang, self.isNsfw ? @"YES" : @"NO",
                                   self.installed ? @"YES" : @"NO", self.hasUpdate ? @"YES" : @"NO",
                                   self.obsolete ? @"YES" : @"NO"];
}

@end
