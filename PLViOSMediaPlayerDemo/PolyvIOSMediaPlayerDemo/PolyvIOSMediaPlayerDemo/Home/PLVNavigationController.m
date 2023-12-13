//
//  PLVNavigationController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by lichangjie on 2023/12/6.
//

#import "PLVNavigationController.h"
#import "PLVDemoVodMediaViewController.h"
#import "PLVDemoVideoFeedViewController.h"

@interface PLVNavigationController ()

@end

@implementation PLVNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate{
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([self.visibleViewController isKindOfClass:[UIAlertController class]]) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return [self.visibleViewController supportedInterfaceOrientations];
    }
}


@end

