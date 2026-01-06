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
    (void)info;
    (void)size;
    free((void *)data);
}

@implementation YGRImageUtility

+ (UIImage *) imageWithWebPData:(NSData *)data
                          scale:(CGFloat)scale
                    fittingSize:(CGSize)fittingSize
                          error:(NSError * __autoreleasing *)error
{
    int width = 0;
    int height = 0;
    
    if (!WebPGetInfo(data.bytes, data.length, &width, &height))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:YGRImageUtilityDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid WebP data or header formatting error"}];
        }
        return nil;
    }
    
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:YGRImageUtilityDomain
                                         code:-2
                                     userInfo:@{NSLocalizedDescriptionKey:@"Failed to initialize WebP decoder"}];
        }
        return nil;
    }
    
    config.output.colorspace = MODE_RGBA;
    config.options.bypass_filtering = true;
    config.options.no_fancy_upsampling = true;
    config.options.use_threads = true;
    
    if (fittingSize.width > 0.0f && fittingSize.height > 0.0f)
    {
        CGFloat widthScale = fittingSize.width / (CGFloat)width;
        CGFloat heightScale = fittingSize.height / (CGFloat)height;
        CGFloat sizeScale = MIN(widthScale, heightScale);
        
        config.options.use_scaling = true;
        config.options.scaled_width = (int)(width * sizeScale);
        config.options.scaled_height = (int)(height * sizeScale);
    }
    
    VP8StatusCode status = WebPDecode(data.bytes, data.length, &config);
    if (status != VP8_STATUS_OK)
    {
        if (error) {
            *error = [NSError errorWithDomain:YGRImageUtilityDomain
                                         code:-3
                                     userInfo:@{NSLocalizedDescriptionKey:
                      [NSString stringWithFormat:@"WebP decode failed (%d)", status]}];
        }
        WebPFreeDecBuffer(&config.output);
        return nil;
    }
    
    size_t bytesPerRow = bytesPerPixel * config.output.width;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(
        NULL,
        config.output.u.RGBA.rgba,
        config.output.width * config.output.height * bytesPerPixel,
        WebPFreeImageData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    
    CGImageRef imageRef = CGImageCreate(
        config.output.width,
        config.output.height,
        bitsPerComponent,
        bitsPerPixel,
        bytesPerRow,
        colorSpace,
        bitmapInfo,
        provider,
        NULL,
        YES,
        kCGRenderingIntentDefault);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef
                                         scale:scale
                                   orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    
    return image;
}

+ (UIImage *)imageFromData:(NSData *)data
                  mimeType:(NSString *)mimeType
                     error:(NSError * __autoreleasing *)error
{
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:@"YGRImageUtility"
                                         code:-10
                                     userInfo:@{NSLocalizedDescriptionKey:@"No data provided"}];
        }
        return nil;
    }
    
    // Normalize content-type
    NSString *type = mimeType.lowercaseString;
    NSLog(@"MIME-Type: %@", type);
    
    // Check for WebP
    if ([type isEqualToString:@"image/webp"]) {
        return [YGRImageUtility imageWithWebPData:data
                                           scale:[UIScreen mainScreen].scale
                                     fittingSize:CGSizeZero
                                           error:error];
    }
    
    // Otherwise, decode normally
    UIImage *image = [UIImage imageWithData:data];
    
    if (!image && error) {
        *error = [NSError errorWithDomain:@"YGRImageUtility"
                                     code:-11
                                 userInfo:@{NSLocalizedDescriptionKey:@"Failed to decode image"}];
    }
    return image;
}

@end
