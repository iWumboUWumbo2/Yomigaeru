//
//  YGRUpdateStrategyUtility.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YGRUpdateStrategy)
{
    YGRUpdateStrategyAlwaysUpdate,
    YGRUpdateStrategyOnlyFetchOnce,
};

@interface YGRUpdateStrategyUtility : NSObject

+ (YGRUpdateStrategy)updateStrategyFromString:(NSString *)updateStrategyString;
+ (NSString *)stringFromUpdateStrategy:(YGRUpdateStrategy)strategy;

@end
