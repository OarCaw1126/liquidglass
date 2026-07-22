#import "../LiquidGlass.h"
#import "../Shared/LGBannerCaptureSupport.h"
#import "../Shared/LGHookSupport.h"
#import "../Shared/LGSharedSupport.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface SBHomeScreenWindow : UIWindow
@end

@interface SwipeDownDelegate : NSObject <UIGestureRecognizerDelegate>
@end

@implementation SwipeDownDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; 
}
@end

static SwipeDownDelegate *gestureDelegate;

%hook SBHomeScreenWindow

- (void)setHidden:(BOOL)hidden {
    %orig;
    
    if (!hidden && ![self viewWithTag:2600]) {
        if (!gestureDelegate) {
            gestureDelegate = [[SwipeDownDelegate alloc] init];
        }

        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLiquidSwipe27:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        swipeDown.delegate = gestureDelegate;
        
        [self addGestureRecognizer:swipeDown];
    }
}

%new
- (void)handleLiquidSwipe27:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self viewWithTag:2600]) return;

        CGPoint wallpaperOrigin = CGPointZero;
        UIImage *wallpaperSnap = nil;
        
        if (NSClassFromString(@"LiquidGlassView") != nil) {
            wallpaperSnap = LG_getHomescreenSnapshot(&wallpaperOrigin);
        }

        LiquidGlassView *overlayView = [[LiquidGlassView alloc] initWithFrame:self.bounds 
                                                                     wallpaper:wallpaperSnap 
                                                               wallpaperOrigin:wallpaperOrigin];
        overlayView.tag = 2600;
        
        overlayView.blur = 25.0;
        overlayView.glassThickness = 4.0;
        overlayView.refractionScale = 0.15;
        overlayView.cornerRadius = 0.0; 
        overlayView.updateGroup = LGUpdateGroupLockscreen;

        UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, 120)];
        clockLabel.text = @"12:30";
        clockLabel.textAlignment = NSTextAlignmentCenter;
        clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:90];
        clockLabel.textColor = [UIColor systemRedColor];
        
        clockLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        clockLabel.layer.shadowOffset = CGSizeMake(0, 5);
        clockLabel.layer.shadowOpacity = 0.8;
        clockLabel.layer.shadowRadius = 4.0;
        
        [overlayView addSubview:clockLabel];
        [self addSubview:overlayView];
        
        LG_registerGlassView(overlayView, LGUpdateGroupLockscreen);
        
        overlayView.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
        
        [UIView animateWithDuration:0.4 
                              delay:0 
             usingSpringWithDamping:0.7 
              initialSpringVelocity:1.0 
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
    LiquidGlassView *overlayView = (LiquidGlassView *)sender.view;
    
    [UIView animateWithDuration:0.3 animations:^{
        overlayView.transform = CGAffineTransformMakeTranslation(0, -overlayView.bounds.size.height);
    } completion:^(BOOL finished) {
        LG_unregisterGlassView(overlayView, LGUpdateGroupLockscreen);
        [overlayView removeFromSuperview];
    }];
}

%end
