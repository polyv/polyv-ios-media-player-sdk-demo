//
//  PLVPictureInPictureRestoreManager.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/5.
//

#import "PLVPictureInPictureRestoreManager.h"

@interface PLVPictureInPictureRestoreManager ()
@property (nonatomic, strong) UINavigationController *holdingNavigation;
@end

@implementation PLVPictureInPictureRestoreManager

#pragma mark - [ Life Cycle ]

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - [ Public Method ]

+ (instancetype)sharedInstance {
    static PLVPictureInPictureRestoreManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    return _sharedInstance;
}

- (void)cleanRestoreManager {
    self.holdingViewController = nil;
    self.holdingNavigation = nil;
    self.restoreWithPresent = NO;
}

#pragma mark - [ Private Method ]

#pragma mark - Getter & Setter
- (void)setHoldingViewController:(UIViewController *)holdingViewController {
    _holdingViewController = holdingViewController;
    self.holdingNavigation = holdingViewController.navigationController;
}

#pragma mark - PLVPictureInPictureRestoreDelegate
-(void)plvPictureInPictureRestoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    // 点击画中画恢复按钮，先执行这里的代码执行恢复逻辑，然后再关闭画中画
    if (self.holdingNavigation) {
        NSArray *vcArray = self.holdingNavigation.viewControllers;
        NSInteger index = -1;
        for (NSInteger i = 0; i < vcArray.count; i++) {
            UIViewController *child = vcArray[i];
            if ([child isEqual:self.holdingViewController]) {
                index = i;
            }
        }
        if (index == -1) {
            // 不在导航栈内
            [self.holdingNavigation pushViewController:self.holdingViewController animated:YES];
        }
        else if (index == vcArray.count - 1) {
            // 在栈顶，则直接恢复
        }else {
            [self.holdingNavigation popToViewController:self.holdingViewController animated:YES];
        }
    }
    else {
        UIViewController *currentViewController = [PLVVodFdUtil getCurrentViewController];
        if (currentViewController != self.holdingViewController) {
            if (self.restoreWithPresent) {
                [currentViewController presentViewController:self.holdingViewController animated:YES completion:nil];
            }else {
                [currentViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    [self cleanRestoreManager];
    completionHandler(YES);
}

@end
