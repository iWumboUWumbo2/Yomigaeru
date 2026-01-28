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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _repo = [NSURL URLWithString:[dictionary objectForKey:@"repo"]];
        _apkName = [dictionary objectForKey:@"apkName"];
        _iconUrl =
            [[YGRSettingsManager sharedInstance] URLForPath:[dictionary objectForKey:@"iconUrl"]];
        _name = [dictionary objectForKey:@"name"];
        _lowerName = [_name lowercaseString];
        _pkgName = [dictionary objectForKey:@"pkgName"];
        _versionName = [dictionary objectForKey:@"versionName"];
        _versionCode = [[dictionary objectForKey:@"versionCode"] integerValue];
        _lang = [dictionary objectForKey:@"lang"];
        _isNsfw = [[dictionary objectForKey:@"isNsfw"] boolValue];
        _installed = [[dictionary objectForKey:@"installed"] boolValue];
        _hasUpdate = [[dictionary objectForKey:@"hasUpdate"] boolValue];
        _obsolete = [[dictionary objectForKey:@"obsolete"] boolValue];
    }
    return self;
}

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
