//
//  YGRImageUtility.m
//  Yomigaeru
//
//  Created by John Connery on 2025/11/03.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#import "YGRImageUtility.h"
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
    NSLog(@"MIME-Type: %@", type);

    // Check for WebP
    if ([type isEqualToString:@"image/webp"])
    {
        return [self imageWithWebPData:data targetWidth:(CGFloat) targetWidth error:error];
    }

    // Otherwise, decode normally
    UIImage *image = [UIImage imageWithData:data];

    if (!image && error)
    {
        *error = [NSError errorWithDomain:@"YGRImageUtility"
                                     code:-11
                                 userInfo:@{NSLocalizedDescriptionKey : @"Failed to decode image"}];
    }
    return image;
}

@end
