//
//  YGRUpdateStrategyUtility.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Controls how aggressively a manga's chapter list is refreshed from the source. */
typedef NS_ENUM(NSInteger, YGRUpdateStrategy)
{
    /** Refresh the chapter list from the source every time it's needed. */
    YGRUpdateStrategyAlwaysUpdate,
    /** Fetch the chapter list from the source once, then rely on the local copy. */
    YGRUpdateStrategyOnlyFetchOnce,
};

/**
 *  Converts between the server's upper-snake-case update strategy strings
 *  (e.g. "ALWAYS_UPDATE") and the YGRUpdateStrategy enum used internally.
 */
@interface YGRUpdateStrategyUtility : NSObject

#pragma mark - Conversion

/**
 *  Parses an update strategy string into a YGRUpdateStrategy.
 *
 *  @param updateStrategyString The raw strategy string from the server, e.g.
 *                               "ONLY_FETCH_ONCE". Passing nil, NSNull, or any
 *                               unrecognized string yields YGRUpdateStrategyAlwaysUpdate.
 *
 *  @return The matching YGRUpdateStrategy, defaulting to YGRUpdateStrategyAlwaysUpdate.
 */
+ (YGRUpdateStrategy)updateStrategyFromString:(NSString *)updateStrategyString;

/**
 *  Converts a YGRUpdateStrategy back into the server's string representation.
 *
 *  @param strategy The strategy to convert.
 *
 *  @return The matching upper-snake-case string. Returns "ALWAYS_UPDATE" for
 *          YGRUpdateStrategyAlwaysUpdate or any unrecognized value.
 */
+ (NSString *)stringFromUpdateStrategy:(YGRUpdateStrategy)strategy;

@end
