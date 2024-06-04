//
//  AppDelegate.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/16.
//

#import "AppDelegate.h"
#import "PLVTabBarViewController.h"
#import "PLVNavigationController.h"
#import "PLVEntranceViewController.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface AppDelegate ()

@property (nonatomic, strong) UITabBarController *tabbar;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // tabbar 样式入口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[PLVTabBarViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    // 非tabbar 样式入口
//    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    self.window.rootViewController = [[PLVNavigationController alloc] initWithRootViewController:[[PLVEntranceViewController alloc] init]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];

    [self initMediaPlayerSDK];
    
    return YES;
}

- (void)initMediaPlayerSDK {
    // 配置APP账号
    // 公共账号
    PLVVodMediaSettings *settings = [PLVVodMediaSettings settingsWithUserid:@"e97dbe3e64"
                                                        readtoken:@""
                                                       writetoken:@""
                                                        secretkey:@"zMV29c519P"];
    
    settings.logLevel = PLVVodMediaLogLevelAll;
    settings.viewerInfos.viewerId = @"用户";
    settings.viewerInfos.viewerName = @"User Name";
    settings.viewerInfos.viewerAvatar = @"User Avatar Link";
    settings.viewerInfos.viewerExtraInfo1 = @"Custom param3";
    settings.viewerInfos.viewerExtraInfo2 = @"Custom param4";
    settings.viewerInfos.viewerExtraInfo3 = @"Custom param5";
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return  UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
}

- (void)applicationWillResignActive:(UIApplication *)application{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"applicationWillEnterForeground");

}

@end

