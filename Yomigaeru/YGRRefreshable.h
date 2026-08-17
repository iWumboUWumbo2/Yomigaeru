//
//  YGRRefreshable.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/15.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Adopted by view controllers that can reload their own content on demand. */
@protocol YGRRefreshable <NSObject>

@required

/** Re-fetches and redisplays this object's content. */
- (void)refresh;

@end
