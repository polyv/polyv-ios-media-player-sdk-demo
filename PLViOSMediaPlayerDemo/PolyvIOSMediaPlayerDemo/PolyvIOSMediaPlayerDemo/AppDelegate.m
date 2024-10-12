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
    
    // 下载配置，无需下载功能可以屏蔽
    [self initDownloadSettings];
    
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

- (void)initDownloadSettings {
    // 下载配置参数
    [PLVDownloadManager sharedManager].autoStart = YES;
    [PLVDownloadManager sharedManager].maxRuningCount = 3;
    
    // ！！！注意 注意 注意
    // 旧版本点播升级 配置迁移路径
    [PLVDownloadManager sharedManager].previousDownloadDir = [self getpreviousDownlaodDir];
    
    // 设置登入用户唯一标识 比如手机账号
    [[PLVDownloadManager sharedManager] setAccountID:@"18812345678"];
    
    NSLog(@"DownloadDir: %@", [PLVDownloadManager sharedManager].downloadDir);
}

/// 旧版SDK 默认缓存路径
- (NSString *)getpreviousDownlaodDir{
    // /Library/Cache/PolyvVodCache
    NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"PolyvVodCache"];
    return downloadDir;
}
// 为后台下载进行桥接
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)(void))completionHandler {
    [[PLVDownloadManager sharedManager] handleEventsForBackgroundURLSession:identifier
                                                             completionHandler:completionHandler];
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

