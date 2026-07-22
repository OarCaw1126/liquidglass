#import "../LiquidGlass.h"
#import "../Shared/LGHookSupport.h"
#import "../Shared/LGBannerCaptureSupport.h"
#import "../Shared/LGPrefAccessors.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <string.h>

@interface SBHomeScreenView : UIView
@end

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
        overlayView.layer.opaque = NO;
        overlayView.layer.backgroundColor = [UIColor clearColor].CGColor;
        
        if ([overlayView respondsToSelector:@selector(setBlur:)]) {
            overlayView.blur = 0.0;
        }
        if ([overlayView respondsToSelector:@selector(setGlassThickness:)]) {
            overlayView.glassThickness = 0.0;
        }
        if ([overlayView respondsToSelector:@selector(setRefractionScale:)]) {
            overlayView.refractionScale = 0.0;
        }
        
        // Remover subcapas generadas internamente que agregan desenfoque o filtros de imagen
        for (CALayer *layer in overlayView.layer.sublayers) {
            if ([layer.delegate isKindOfClass:NSClassFromString(@"UIVisualEffectView")] || 
                [layer.name containsString:@"Blur"] || 
                [layer.name containsString:@"Filter"]) {
                [layer removeFromSuperlayer];
            }
        }
        
        UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, 140)];
        clockLabel.text = @"12:30";
        clockLabel.textAlignment = NSTextAlignmentCenter;
        clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:100];
        clockLabel.textColor = [UIColor whiteColor];
        clockLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
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
                         LG_unregisterGlassView(overlayView, 0);
                         [overlayView removeFromSuperview];
                     }];
}

%end
