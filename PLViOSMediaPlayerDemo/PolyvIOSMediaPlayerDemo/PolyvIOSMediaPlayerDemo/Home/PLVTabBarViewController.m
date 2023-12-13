//
//  TabBarViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by lichangjie on 2023/11/24.
//

#import "PLVTabBarViewController.h"
#import "PLVEntranceViewController.h"
#import "PLVDemoVodMediaViewController.h"
#import "PLVDemoVideoFeedViewController.h"
#import "PLVDemoVideoFeedViewController.h"

@interface PLVTabBarViewController ()

@end

@implementation PLVTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIViewController* mainVC = [[PLVEntranceViewController alloc] init];
    UINavigationController *navMain = [[UINavigationController alloc] initWithRootViewController:mainVC];
    navMain.tabBarItem.title = @"主页";
    [navMain.tabBarItem setTitleTextAttributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize:16],
        NSForegroundColorAttributeName: [UIColor blackColor]
    } forState:UIControlStateNormal];
    
    PLVDemoVideoFeedViewController *feedVC = [[PLVDemoVideoFeedViewController alloc] init];
    feedVC.isHideProtraitBackButton = YES;
    UINavigationController *navFeed = [[UINavigationController alloc] initWithRootViewController:feedVC];
    navFeed.tabBarItem.title = @"短视频";
    [navFeed.tabBarItem setTitleTextAttributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize:16],
        NSForegroundColorAttributeName: [UIColor blackColor]
    } forState:UIControlStateNormal];
    
    self.viewControllers = @[navMain, navFeed];
    self.selectedIndex = 0;
    self.tabBar.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotate{
    UIViewController *vc = [self topViewControllerWithRootViewController:self.selectedViewController];
    return [vc shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIViewController *vc = [self topViewControllerWithRootViewController:self.selectedViewController];
    return [vc preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = [self topViewControllerWithRootViewController:self.selectedViewController];
    if ([vc isKindOfClass:[UIAlertController class]]) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return [vc supportedInterfaceOrientations];
    }
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    return rootViewController;
}

@end

