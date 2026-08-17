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
 *  Decodes raw image data into a UIImage, downsampling directly to a bounded
 *  size rather than decoding at full resolution and scaling afterward — this
 *  keeps peak decode memory proportional to @c targetWidth, not to the source
 *  image's actual resolution.
 *
 *  Dispatches to a dedicated WebP decoder when @c mimeType is "image/webp"
 *  (UIImage/ImageIO can't decode WebP on their own), which scales to an exact
 *  width and lets height float proportionally. All other formats (JPEG, PNG,
 *  etc.) decode via ImageIO's thumbnail-generation API, which instead bounds
 *  the *larger* of width/height to @c targetWidth — a stricter, format-
 *  agnostic memory ceiling regardless of the source image's aspect ratio.
 *
 *  @param data        The raw image bytes.
 *  @param mimeType     The content type reported for @c data, e.g. "image/webp"
 *                      or "image/jpeg". Used only to pick the WebP path.
 *  @param targetWidth  The maximum size, in pixels, to downsample the decoded
 *                      image to (see above for exactly which dimension this
 *                      bounds, per format). Images already smaller than this
 *                      are not upscaled.
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
