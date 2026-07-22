#import "../LiquidGlass.h"
#import "../Shared/LGBannerCaptureSupport.h"
#import "../Shared/LGHookSupport.h"
#import "../Shared/LGSharedSupport.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <string.h>

#ifndef kLGBlackImageSampleGrid
#define kLGBlackImageSampleGrid 16
#endif

static void *kLGSnapshotOriginalOpacityKey = &kLGSnapshotOriginalOpacityKey;

BOOL LG_imageLooksBlack(UIImage *img) {
    if (!img) return YES;
    CGImageRef cg = img.CGImage;
    if (!cg) return YES;
    
    int total_px_1 = kLGBlackImageSampleGrid * kLGBlackImageSampleGrid * 4;
    unsigned char px[total_px_1];
    memset(px, 0, total_px_1);
    
    CGContextRef ctx = CGBitmapContextCreate(px,
                                             kLGBlackImageSampleGrid,
                                             kLGBlackImageSampleGrid,
                                             8,
                                             kLGBlackImageSampleGrid * 4,
                                             LGSharedRGBColorSpace(),
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!ctx) return YES;
    CGContextDrawImage(ctx, CGRectMake(0, 0, kLGBlackImageSampleGrid, kLGBlackImageSampleGrid), cg);
    CGContextRelease(ctx);
    NSUInteger sampleCount = kLGBlackImageSampleGrid * kLGBlackImageSampleGrid;
    uint8_t brightestChannel = 0;
    for (NSUInteger i = 0; i < sampleCount; i++) {
        uint8_t r = px[i * 4];
        uint8_t g = px[i * 4 + 1];
        uint8_t b = px[i * 4 + 2];
        brightestChannel = MAX(brightestChannel, MAX(r, MAX(g, b)));
        if (brightestChannel > 1) return NO;
    }
    return YES;
}

static NSNumber *sLockscreenWallpaperIsLight = nil;

BOOL LG_imageIsLight(UIImage *img) {
    if (!img) return NO;
    CGImageRef cg = img.CGImage;
    if (!cg) return NO;

    const size_t grid = 16;
    int total_px_2 = grid * grid * 4;
    unsigned char px[total_px_2];
    memset(px, 0, total_px_2);
    
    CGContextRef ctx = CGBitmapContextCreate(px,
                                             grid,
                                             grid,
                                             8,
                                             grid * 4,
                                             LGSharedRGBColorSpace(),
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!ctx) return NO;
    CGContextDrawImage(ctx, CGRectMake(0, 0, grid, grid), cg);
    CGContextRelease(ctx);

    NSUInteger sampleCount = grid * grid;
    NSUInteger lightPixels = 0;
    double totalLuminance = 0.0;

    for (NSUInteger i = 0; i < sampleCount; i++) {
        uint8_t r = px[i * 4];
        uint8_t g = px[i * 4 + 1];
        uint8_t b = px[i * 4 + 2];

        double luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
        totalLuminance += luminance;

        if (luminance > 0.65) {
            lightPixels++;
        }
    }

    double averageLuminance = totalLuminance / sampleCount;
    double lightRatio = (double)lightPixels / sampleCount;

    return (averageLuminance > 0.6 || lightRatio > 0.3);
}
