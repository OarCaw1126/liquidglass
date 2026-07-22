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
                         LG_unregisterGlassView(overlayView, 0);
                         [overlayView removeFromSuperview];
                     }];
}

%end
