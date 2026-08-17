//
//  YGRImageUtility.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/03.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Decodes image data (including WebP, which UIImage can't handle natively) into a UIImage. */
@interface YGRImageUtility : NSObject

#pragma mark - Decoding

/**
 *  Decodes raw image data into a UIImage, downscaling to a target width.
 *
 *  Dispatches to a dedicated WebP decoder when @c mimeType is "image/webp"
 *  (UIImage can't decode WebP on its own); otherwise decodes via
 *  +[UIImage imageWithData:].
 *
 *  @param data        The raw image bytes.
 *  @param mimeType     The content type reported for @c data, e.g. "image/webp"
 *                      or "image/jpeg". Used only to pick the WebP path.
 *  @param targetWidth  The width, in points, to scale the decoded image to
 *                      (aspect ratio preserved). Only honored on the WebP path.
 *  @param error        On failure, set to an NSError describing what went wrong
 *                      (invalid/missing data, unsupported format, decode failure).
 *
 *  @return The decoded UIImage, or nil if decoding failed.
 */
+ (UIImage *)imageFromData:(NSData *)data
                  mimeType:(NSString *)mimeType
               targetWidth:(CGFloat)targetWidth
                     error:(NSError *__autoreleasing *)error;

@end
