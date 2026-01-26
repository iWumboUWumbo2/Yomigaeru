//
//  YGRImageUtility.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/03.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRImageUtility : NSObject

+ (UIImage *)imageFromData:(NSData *)data
                  mimeType:(NSString *)mimeType
               targetWidth:(CGFloat)targetWidth
                     error:(NSError *__autoreleasing *)error;

@end
