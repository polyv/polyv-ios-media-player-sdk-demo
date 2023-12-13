//
//  PLVOrientationUtil.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by lichangjie on 2023/11/29.
//

#import "PLVOrientationUtil.h"

@implementation PLVOrientationUtil

+ (Boolean)isLandscape {
    return [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
}

+ (void)changeUIOrientation:(UIDeviceOrientation)orientation {
    if (@available(iOS 16.0, *)) {
        UIViewController *currentVC = [PLVOrientationUtil getCurrentViewController];
        if (currentVC && [currentVC respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)]) {
            [currentVC performSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)];
        }
        
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAllButUpsideDown;
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            mask = UIInterfaceOrientationMaskLandscape;
        } else {
            mask = UIInterfaceOrientationMaskPortrait;
        }
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *windowScene = (UIWindowScene *)array.firstObject;
        Class UIWindowSceneGeometryPreferencesIOSClass = NSClassFromString(@"UIWindowSceneGeometryPreferencesIOS");
        id geometryPreferences = [[UIWindowSceneGeometryPreferencesIOSClass alloc] init];
        if (geometryPreferences) {
            [geometryPreferences setValue:@(mask) forKey:@"interfaceOrientations"];
            SEL sel_method = NSSelectorFromString(@"requestGeometryUpdateWithPreferences:errorHandler:");
            void (^errorHandler)(NSError *error) = ^(NSError *error) {
                NSLog(@"iOS16旋转屏幕错误_%@", error);
            };
            if ([windowScene respondsToSelector:sel_method]) {
                (((void (*)(id, SEL,id,id))[windowScene methodForSelector:sel_method])(windowScene, sel_method, geometryPreferences, errorHandler));
            }
        }
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = (int)orientation;
            [invocation setArgument:&val atIndex:2];//从2开始，因为0 1 两个参数已经被selector和target占用
            [invocation invoke];
        }
    }
}

+ (void)setNeedsUpdateOfSupportedInterfaceOrientations {
    if (@available(iOS 16.0, *)) {
        UIViewController *currentVC = [PLVOrientationUtil getCurrentViewController];
        if (currentVC && [currentVC respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)]) {
            [currentVC performSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)];
        }
    }
}

+ (UIViewController *)getCurrentViewController{
    UIViewController* currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                currentViewController = currentViewController.childViewControllers.lastObject;
                return currentViewController;
            } else {
                return currentViewController;
            }
        }
    }
    return currentViewController;
}

@end
