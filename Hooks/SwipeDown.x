#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <string.h>

#ifndef kLGBlackImageSampleGrid
#define kLGBlackImageSampleGrid 16
#endif

extern CGColorSpaceRef LGSharedRGBColorSpace(void);

static void *kLGSnapshotOriginalOpacityKey = &kLGSnapshotOriginalOpacityKey;

static BOOL LG_imageLooksBlack(UIImage *img) {
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

static BOOL LG_imageIsLight(UIImage *img) {
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

%hook SBHomeScreenView

%new
- (void)handleLiquidSwipe27:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self viewWithTag:2600]) return;

        LiquidGlassView *overlayView = [[LiquidGlassView alloc] initWithFrame:self.bounds 
                                                                     wallpaper:nil 
                                                               wallpaperOrigin:CGPointZero];
        overlayView.tag = 2600;
        overlayView.backgroundColor = [UIColor clearColor];
        overlayView.opaque = NO;
        
        overlayView.blur = 0.0;
        
        overlayView.glassThickness = 1.0;
        overlayView.refractionScale = 0.15;
        overlayView.cornerRadius = 0.0;
        overlayView.clipsToBounds = YES;
        overlayView.layer.masksToBounds = YES;
        
        UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, 140)];
        clockLabel.text = @"19:14";
        clockLabel.textAlignment = NSTextAlignmentCenter;
        clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:100];
        clockLabel.textColor = [UIColor whiteColor];
        clockLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        clockLabel.shadowOffset = CGSizeMake(0, 2);
        
        [overlayView addSubview:clockLabel];
        [self addSubview:overlayView];
        
        overlayView.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
        
        [UIView animateWithDuration:0.45 
                              delay:0 
             usingSpringWithDamping:0.85 
              initialSpringVelocity:0.8 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             overlayView.transform = CGAffineTransformIdentity;
                         } completion:nil];
                         
        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLiquidOverlay27:)];
        [overlayView addGestureRecognizer:dismissTap];
    }
}

%new
- (void)dismissLiquidOverlay27:(UITapGestureRecognizer *)sender {
    UIView *overlayView = [self viewWithTag:2600];
    if (!overlayView) return;

    [UIView animateWithDuration:0.3 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         overlayView.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
                     } completion:^(BOOL finished) {
                         if (NSClassFromString(@"LiquidGlassView") != nil) {
                             LG_unregisterGlassView((LiquidGlassView *)overlayView);
                         }
                         [overlayView removeFromSuperview];
                     }];
}

%end
