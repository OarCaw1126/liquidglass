#import <UIKit/UIKit.h>

@interface CCUIModuleCollectionView : UIView
@end

@interface CCUIOverlayViews : UIView
@end

%hook CCUIModuleCollectionView

- (void)layoutSubviews {
    %orig;

    UIView *darkOverlay = [self viewWithTag:99905];
    if (!darkOverlay) {
        darkOverlay = [[UIView alloc] initWithFrame:self.bounds];
        darkOverlay.tag = 99905;
        darkOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.50];
        darkOverlay.userInteractionEnabled = NO;
        darkOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:darkOverlay atIndex:0];
    } else {
        darkOverlay.frame = self.bounds;
        [self sendSubviewToBack:darkOverlay];
    }
}

%end

%hook CCUIOverlayViews

- (void)layoutSubviews {
    %orig;

    UIView *darkOverlay = [self viewWithTag:99906];
    if (!darkOverlay) {
        darkOverlay = [[UIView alloc] initWithFrame:self.bounds];
        darkOverlay.tag = 99906;
        darkOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.50];
        darkOverlay.userInteractionEnabled = NO;
        darkOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:darkOverlay atIndex:0];
    } else {
        darkOverlay.frame = self.bounds;
        [self sendSubviewToBack:darkOverlay];
    }
}

%end
