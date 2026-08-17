//
//  YGRChildRefreshDelegate.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/15.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Adopted by a container (e.g. a parent view controller) that hosts a child
 *  which independently refreshes its own data, so the child can report back
 *  when it's done.
 */
@protocol YGRChildRefreshDelegate <NSObject>

@required

/** Called by the child once its own refresh has completed. */
- (void)childDidFinishRefreshing;

@end
