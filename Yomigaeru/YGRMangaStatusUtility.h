//
//  YGRMangaStatusUtility.h
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    YGRMangaStatusUnknown = 0,
    YGRMangaStatusOngoing = 1,
    YGRMangaStatusCompleted = 2,
    YGRMangaStatusLicensed = 3,
    YGRMangaStatusPublishingFinished = 4,
    YGRMangaStatusCancelled = 5,
    YGRMangaStatusOnHiatus = 6,
} YGRMangaStatus;

@interface YGRMangaStatusUtility : NSObject

+ (YGRMangaStatus)mangaStatusFromString:(NSString *)statusString;
+ (NSString *)stringFromMangaStatus:(YGRMangaStatus)status;

@end
