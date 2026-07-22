#import <UIKit/UIKit.h>

@interface CCUIHeaderPocketView : UIView
@end

@interface CCUIMainViewController : UIViewController
@end

%hook CCUIHeaderPocketView

- (void)layoutSubviews {
    %orig;

    UIView *darkBackdrop = [self viewWithTag:99903];
    if (!darkBackdrop) {
        darkBackdrop = [[UIView alloc] initWithFrame:self.bounds];
        darkBackdrop.tag = 99903;
        darkBackdrop.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.60];
        darkBackdrop.userInteractionEnabled = NO;
        darkBackdrop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:darkBackdrop atIndex:0];
    } else {
        darkBackdrop.frame = self.bounds;
    }
}

%end

%hook CCUIMainViewController

- (void)viewDidLayoutSubviews {
    %orig;

    UIView *mainView = self.view;
    UIView *bgOverlay = [mainView viewWithTag:99904];
    if (!bgOverlay) {
        bgOverlay = [[UIView alloc] initWithFrame:mainView.bounds];
        bgOverlay.tag = 99904;
        bgOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.60];
        bgOverlay.userInteractionEnabled = NO;
        bgOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [mainView insertSubview:bgOverlay atIndex:0];
    } else {
        bgOverlay.frame = mainView.bounds;
        [mainView sendSubviewToBack:bgOverlay];
    }
}

%end
