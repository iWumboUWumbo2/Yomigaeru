//
//  YGRMangaInfoViewController.h
//  Yomigaeru
//
//  Created by John Connery on 2026/01/26.
//  Copyright (c) 2026年 Wumbo World. All rights reserved.
//

#import "YGRManga.h"
#import <UIKit/UIKit.h>

/**
 *  Displays a manga's metadata — title, author, artist, status, genres,
 *  and description — fetched from the server, given only its identifier.
 */
@interface YGRMangaInfoViewController : UITableViewController

/** The identifier of the manga to fetch and display info for. */
@property (nonatomic, copy) NSString *mangaId;

@end
