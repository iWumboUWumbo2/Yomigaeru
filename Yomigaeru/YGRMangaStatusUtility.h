//
//  YGRMangaStatusUtility.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The publication status of a manga, as reported by the source. */
typedef NS_ENUM(NSInteger, YGRMangaStatus)
{
    YGRMangaStatusUnknown = 0,
    YGRMangaStatusOngoing = 1,
    YGRMangaStatusCompleted = 2,
    YGRMangaStatusLicensed = 3,
    YGRMangaStatusPublishingFinished = 4,
    YGRMangaStatusCancelled = 5,
    YGRMangaStatusOnHiatus = 6,
};

/**
 *  Converts between the server's uppercase-snake-case manga status strings
 *  (e.g. "ONGOING", "ON_HIATUS") and the YGRMangaStatus enum used internally.
 */
@interface YGRMangaStatusUtility : NSObject

#pragma mark - Conversion

/**
 *  Parses a manga status string into a YGRMangaStatus.
 *
 *  @param statusString The raw status string from the server, e.g. "ONGOING".
 *                       Passing nil or NSNull yields YGRMangaStatusUnknown, as
 *                       does any string that doesn't match a known status.
 *
 *  @return The matching YGRMangaStatus, or YGRMangaStatusUnknown if unrecognized.
 */
+ (YGRMangaStatus)mangaStatusFromString:(NSString *)statusString;

/**
 *  Converts a YGRMangaStatus back into the server's string representation.
 *
 *  @param status The status to convert.
 *
 *  @return The matching uppercase-snake-case string, e.g. "ONGOING". Returns
 *          "UNKNOWN" for YGRMangaStatusUnknown or any unrecognized value.
 */
+ (NSString *)stringFromMangaStatus:(YGRMangaStatus)status;

@end
