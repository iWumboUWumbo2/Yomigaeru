//
//  YGRUpdateStrategyUtility.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRUpdateStrategyUtility.h"

@implementation YGRUpdateStrategyUtility

#pragma mark - Conversion

+ (YGRUpdateStrategy)updateStrategyFromString:(NSString *)updateStrategyString
{
    if (!updateStrategyString || [updateStrategyString isEqual:[NSNull null]])
    {
        return YGRUpdateStrategyAlwaysUpdate;
    }

    if ([updateStrategyString isEqualToString:@"ONLY_FETCH_ONCE"])
    {
        return YGRUpdateStrategyOnlyFetchOnce;
    }
    else if ([updateStrategyString isEqualToString:@"ALWAYS_UPDATE"])
    {
        return YGRUpdateStrategyAlwaysUpdate;
    }

    return YGRUpdateStrategyAlwaysUpdate;
}

+ (NSString *)stringFromUpdateStrategy:(YGRUpdateStrategy)strategy
{
    switch (strategy)
    {
    case YGRUpdateStrategyOnlyFetchOnce:
        return @"ONLY_FETCH_ONCE";
    case YGRUpdateStrategyAlwaysUpdate:
    default:
        return @"ALWAYS_UPDATE";
    }
}

@end
