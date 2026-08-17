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
 *  Decodes raw image data into a UIImage, downsampling directly to a target
 *  width rather than decoding at full resolution and scaling afterward — this
 *  keeps peak decode memory proportional to @c targetWidth, not to the source
 *  image's actual resolution.
 *
 *  Dispatches to a dedicated WebP decoder when @c mimeType is "image/webp"
 *  (UIImage/ImageIO can't decode WebP on their own); all other formats (JPEG,
 *  PNG, etc.) decode via ImageIO's thumbnail-generation API instead. Both
 *  paths scale to the same effective result: the decoded image's *width*
 *  matches @c targetWidth, with height floating proportionally (aspect ratio
 *  preserved) and uncapped — so very tall images (e.g. webcomic-style long
 *  strips) still come out full-height at the target width, rather than
 *  getting shrunk to fit some arbitrary height ceiling. A caller displaying
 *  the image at that width never needs to upscale it.
 *
 *  @param data        The raw image bytes.
 *  @param mimeType     The content type reported for @c data, e.g. "image/webp"
 *                      or "image/jpeg". Used only to pick the WebP path.
 *  @param targetWidth  The width, in pixels, to downsample the decoded image
 *                      to. Images already narrower than this are not upscaled.
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
