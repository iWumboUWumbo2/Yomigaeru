//
//  YGRImageUtility.m
//  Yomigaeru
//
//  Created by John Connery on 2025/11/03.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRImageUtility.h"
#import <ImageIO/ImageIO.h>
#import <WebP/decode.h>
#import <WebP/encode.h>

static NSString *YGRImageUtilityDomain = @"YGRImageUtility";

static const size_t bitsPerComponent = 8;
static const size_t bitsPerPixel = 32;
static const size_t bytesPerPixel = 4;

static void WebPFreeImageData(void *info, const void *data, size_t size)
{
    (void) info;
    (void) size;
    free((void *) data);
}

@implementation YGRImageUtility

#pragma mark - Private WebP Decoding

/**
 *  Decodes WebP-encoded image data into a UIImage via libwebp, downscaling to
 *  a target width while preserving aspect ratio.
 *
 *  @param data        The raw WebP-encoded bytes.
 *  @param targetWidth The width, in points, to scale the decoded image to.
 *  @param error       On failure, set to an NSError describing what went wrong
 *                     (invalid data, decoder init failure, decode failure).
 *
 *  @return The decoded UIImage, or nil if decoding failed.
 */
+ (UIImage *)imageWithWebPData:(NSData *)data
                   targetWidth:(CGFloat)targetWidth
                         error:(NSError *__autoreleasing *)error
{
    if (!data || targetWidth <= 0)
    {
        if (error)
            *error =
                [NSError errorWithDomain:YGRImageUtilityDomain
                                    code:-10
                                userInfo:@{NSLocalizedDescriptionKey : @"Invalid data or width"}];
        return nil;
    }

    int width = 0;
    int height = 0;
    if (!WebPGetInfo(data.bytes, data.length, &width, &height))
    {
        if (error)
            *error = [NSError errorWithDomain:YGRImageUtilityDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey : @"Invalid WebP data"}];
        return nil;
    }

    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config))
    {
        if (error)
            *error = [NSError
                errorWithDomain:YGRImageUtilityDomain
                           code:-2
                       userInfo:@{NSLocalizedDescriptionKey : @"Failed to init WebP decoder"}];
        return nil;
    }

    config.output.colorspace = MODE_RGBA;
    config.options.bypass_filtering = true;
    config.options.no_fancy_upsampling = true;
    config.options.use_threads = ([NSProcessInfo processInfo].processorCount > 1);

    // Scale to target width, keeping aspect ratio
    CGFloat scaleFactor = targetWidth / (CGFloat) width;
    config.options.use_scaling = true;
    config.options.scaled_width = (int) (width * scaleFactor);
    config.options.scaled_height = (int) (height * scaleFactor);

    VP8StatusCode status = WebPDecode(data.bytes, data.length, &config);
    if (status != VP8_STATUS_OK)
    {
        if (error)
            *error = [NSError errorWithDomain:YGRImageUtilityDomain
                                         code:-3
                                     userInfo:@{
                                         NSLocalizedDescriptionKey : [NSString
                                             stringWithFormat:@"WebP decode failed (%d)", status]
                                     }];
        WebPFreeDecBuffer(&config.output);
        return nil;
    }

    size_t bytesPerRow = 4 * config.output.width;

    CGDataProviderRef provider = CGDataProviderCreateWithData(
        NULL, config.output.u.RGBA.rgba, config.output.width * config.output.height * 4,
        WebPFreeImageData);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;

    CGImageRef imageRef =
        CGImageCreate(config.output.width, config.output.height, 8, 32, bytesPerRow, colorSpace,
                      bitmapInfo, provider, NULL, YES, kCGRenderingIntentDefault);

    UIImage *image = [UIImage imageWithCGImage:imageRef
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationUp];

    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);

    return image;
}

#pragma mark - Private Downsampled Decoding

/**
 *  Decodes image data (JPEG, PNG, etc. — anything ImageIO understands) directly
 *  at a reduced pixel size via `CGImageSourceCreateThumbnailAtIndex`, instead of
 *  decoding at full resolution and only then scaling. This keeps peak decode
 *  memory bounded to roughly the target size rather than the source image's
 *  actual resolution, which matters a lot on memory-constrained devices: a
 *  decoded bitmap costs `width * height * 4` bytes regardless of how
 *  compressed the source file was.
 *
 *  Scales to an exact width, matching +imageWithWebPData:targetWidth:error:
 *  above: ImageIO's thumbnail API only lets you bound whichever dimension is
 *  *larger* to a max pixel size, which for portrait images (like manga pages,
 *  taller than wide) would bound height and leave the resulting width smaller
 *  than intended — forcing whatever displays it to upscale, and blurring text
 *  in the process. To avoid that, this reads the source's actual pixel
 *  dimensions first and computes the max-pixel-size ImageIO needs in order
 *  for the *width* to come out to targetWidth. Height is left to float
 *  however tall it needs to be (this app also serves webcomic-style long
 *  strips, which can be far taller than they are wide) — aggregate memory
 *  across many cached pages is bounded by the cache's own totalCostLimit/
 *  countLimit instead of by capping any single image's height here.
 *
 *  @param data        The raw encoded image bytes.
 *  @param targetWidth The width, in pixels, to scale the decoded image to.
 *                      Images already narrower than this are not upscaled.
 *  @param error       On failure, set to an NSError describing what went wrong.
 *
 *  @return The decoded, downsampled UIImage, or nil if decoding failed.
 */
+ (UIImage *)downsampledImageWithData:(NSData *)data
                           targetWidth:(CGFloat)targetWidth
                                 error:(NSError *__autoreleasing *)error
{
    if (!data || targetWidth <= 0)
    {
        if (error)
            *error =
                [NSError errorWithDomain:YGRImageUtilityDomain
                                    code:-20
                                userInfo:@{NSLocalizedDescriptionKey : @"Invalid data or width"}];
        return nil;
    }

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    if (!source)
    {
        if (error)
            *error = [NSError
                errorWithDomain:YGRImageUtilityDomain
                           code:-21
                       userInfo:@{NSLocalizedDescriptionKey : @"Failed to create image source"}];
        return nil;
    }

    CGFloat maxPixelSize = targetWidth;
    NSDictionary *properties =
        (__bridge_transfer NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    CGFloat sourceWidth = [properties[(__bridge NSString *) kCGImagePropertyPixelWidth] doubleValue];
    CGFloat sourceHeight = [properties[(__bridge NSString *) kCGImagePropertyPixelHeight] doubleValue];

    if (sourceWidth > 0 && sourceHeight > 0 && sourceWidth > targetWidth)
    {
        CGFloat scaleFactor = targetWidth / sourceWidth;
        maxPixelSize = sourceHeight * scaleFactor;
    }

    NSLog(@"[YGR-DEBUG] ImageUtility downsampled sourceWidth=%.1f sourceHeight=%.1f "
          @"targetWidth=%.1f maxPixelSize=%.1f",
          sourceWidth, sourceHeight, targetWidth, maxPixelSize);

    NSDictionary *thumbnailOptions = @{
        (__bridge NSString *) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
        (__bridge NSString *) kCGImageSourceThumbnailMaxPixelSize : @(maxPixelSize),
        (__bridge NSString *) kCGImageSourceCreateThumbnailWithTransform : @YES,
    };

    CGImageRef thumbnailRef =
        CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) thumbnailOptions);
    CFRelease(source);

    if (!thumbnailRef)
    {
        if (error)
            *error = [NSError
                errorWithDomain:YGRImageUtilityDomain
                           code:-22
                       userInfo:@{NSLocalizedDescriptionKey : @"Failed to decode image"}];
        return nil;
    }

    UIImage *image = [UIImage imageWithCGImage:thumbnailRef
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationUp];
    CGImageRelease(thumbnailRef);

    return image;
}

#pragma mark - Public API

+ (UIImage *)imageFromData:(NSData *)data
                  mimeType:(NSString *)mimeType
               targetWidth:(CGFloat)targetWidth
                     error:(NSError *__autoreleasing *)error
{
    if (!data)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"YGRImageUtility"
                                         code:-10
                                     userInfo:@{NSLocalizedDescriptionKey : @"No data provided"}];
        }
        return nil;
    }

    // Normalize content-type
    NSString *type = mimeType.lowercaseString;
    NSLog(@"[YGR-DEBUG] ImageUtility imageFromData MIME-Type=%@ dataLength=%lu targetWidth=%.1f",
          type, (unsigned long) data.length, targetWidth);

    // Check for WebP
    if ([type isEqualToString:@"image/webp"])
    {
        UIImage *image = [self imageWithWebPData:data targetWidth:(CGFloat) targetWidth error:error];
        NSLog(@"[YGR-DEBUG] ImageUtility imageFromData WebP path result image=%@ error=%@", image,
              error ? *error : nil);
        return image;
    }

    // Otherwise, decode via ImageIO, downsampling directly to targetWidth so we
    // never materialize a full-resolution bitmap for images we're about to shrink.
    UIImage *image = [self downsampledImageWithData:data targetWidth:targetWidth error:error];
    NSLog(@"[YGR-DEBUG] ImageUtility imageFromData ImageIO path result image=%@ error=%@", image,
          error ? *error : nil);
    return image;
}

@end
