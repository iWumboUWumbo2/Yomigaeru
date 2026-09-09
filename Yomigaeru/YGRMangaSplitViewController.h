//
//  YGRMangaSplitViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/09/09.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGRManga.h"

/**
 *  On iPad, shows a manga's chapter list (YGRMangaViewController) and its
 *  info screen (YGRMangaInfoViewController) side by side, each in its own
 *  navigation controller, as an alternative to the iPhone's push-based
 *  navigation between the two.
 *
 *  This is a plain UIViewController laying the two panes out itself, not a
 *  real UISplitViewController: on this app's deployment target (iOS 5,
 *  built against the iOS 7.1 SDK), UISplitViewController may only be used
 *  as the window's rootViewController — UIKit refuses to push or present
 *  one anywhere else. Since this screen is reached by pushing/presenting
 *  from the existing tab-bar-rooted navigation, a real UISplitViewController
 *  isn't usable here without redesigning the app's whole iPad navigation
 *  around it. This gives the same side-by-side result within that
 *  constraint. Presented modally; the detail pane carries a Done button to
 *  dismiss.
 */
@interface YGRMangaSplitViewController : UIViewController

/**
 *  Creates a split view controller showing the given manga's chapters and
 *  info side by side.
 *
 *  @param manga The manga to display.
 *
 *  @return An initialized YGRMangaSplitViewController instance.
 */
- (instancetype)initWithManga:(YGRManga *)manga;

@end
