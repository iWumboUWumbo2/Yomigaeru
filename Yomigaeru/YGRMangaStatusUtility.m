//
//  YGRMangaStatusUtility.m
//  Yomigaeru
//
//  Created by John Connery on 2025/10/19.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRMangaStatusUtility.h"

@implementation YGRMangaStatusUtility

+ (YGRMangaStatus)mangaStatusFromString:(NSString *)statusString
{
    if (!statusString || [statusString isEqual:[NSNull null]])
    {
        return YGRMangaStatusUnknown;
    }
    
    if ([statusString isEqualToString:@"ONGOING"])
    {
        return YGRMangaStatusOngoing;
    }
    else if ([statusString isEqualToString:@"COMPLETED"])
    {
        return YGRMangaStatusCompleted;
    }
    else if ([statusString isEqualToString:@"LICENSED"])
    {
        return YGRMangaStatusLicensed;
    }
    else if ([statusString isEqualToString:@"PUBLISHING_FINISHED"])
    {
        return YGRMangaStatusPublishingFinished;
    }
    else if ([statusString isEqualToString:@"CANCELLED"])
    {
        return YGRMangaStatusCancelled;
    }
    else if ([statusString isEqualToString:@"ON_HIATUS"])
    {
        return YGRMangaStatusOnHiatus;
    }
    
    return YGRMangaStatusUnknown;
}


+ (NSString *)stringFromMangaStatus:(YGRMangaStatus)status {
    switch (status) {
        case YGRMangaStatusOngoing:
            return @"ONGOING";
        case YGRMangaStatusCompleted:
            return @"COMPLETED";
        case YGRMangaStatusLicensed:
            return @"LICENSED";
        case YGRMangaStatusPublishingFinished:
            return @"PUBLISHING_FINISHED";
        case YGRMangaStatusCancelled:
            return @"CANCELLED";
        case YGRMangaStatusOnHiatus:
            return @"ON_HIATUS";
        case YGRMangaStatusUnknown:
        default:
            return @"UNKNOWN";
    }
}

@end
