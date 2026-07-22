#import <UIKit/UIKit.dylib>

@interface CCUIOverlayViews : UIView
@end

@interface CCUIContentModuleContainerView : UIView
@end

%hook CCUIOverlayViews

- (void)layoutSubviews {
    %orig;

    UIView *darkOverlay = [self viewWithTag:99901];
    
    if (!darkOverlay) {
        darkOverlay = [[UIView alloc] initWithFrame:self.bounds];
        darkOverlay.tag = 99901;
        darkOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.45]; 
        darkOverlay.userInteractionEnabled = NO;
        darkOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self insertSubview:darkOverlay atIndex:0];
    } else {
        darkOverlay.frame = self.bounds;
    }
}

%end

%hook CCUIContentModuleContainerView

- (void)layoutSubviews {
    %orig;
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
    self.layer.cornerRadius = 19.0;
    self.clipsToBounds = YES;
}

%end
