//
//  AppDelegate.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/16.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self initMediaPlayerSDK];
    
    return YES;
}

- (void)initMediaPlayerSDK {
    // 配置APP账号
    // 公共账号
    PLVVodSettings *settings = [PLVVodSettings settingsWithUserid:@"e97dbe3e64"
                                                        readtoken:@""
                                                       writetoken:@""
                                                        secretkey:@"zMV29c519P"];
    
    settings.logLevel = PLVVodLogLevelAll;
    settings.viewerInfos.viewerId = @"用户";
    settings.viewerInfos.viewerName = @"User Name";
    settings.viewerInfos.viewerAvatar = @"User Avatar Link";
    settings.viewerInfos.viewerExtraInfo1 = @"Custom param3";
    settings.viewerInfos.viewerExtraInfo2 = @"Custom param4";
    settings.viewerInfos.viewerExtraInfo3 = @"Custom param5";
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.isSupportLandscape){
        return  UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    }
    else{
        return  UIInterfaceOrientationMaskPortrait;
    }
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

#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
