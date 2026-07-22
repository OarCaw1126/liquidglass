#import <UIKit/UIKit.h>

@interface CCUIOverlayViews : UIView
@end

%hook CCUIOverlayViews

- (void)layoutSubviews {
    %orig;

    UIView *darkBackgroundOverlay = [self viewWithTag:99901];
    
    if (!darkBackgroundOverlay) {
        darkBackgroundOverlay = [[UIView alloc] initWithFrame:self.bounds];
        darkBackgroundOverlay.tag = 99901;
        darkBackgroundOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.50]; 
        darkBackgroundOverlay.userInteractionEnabled = NO;
        darkBackgroundOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self insertSubview:darkBackgroundOverlay atIndex:0];
    } else {
        darkBackgroundOverlay.frame = self.bounds;
    }
}

%end
