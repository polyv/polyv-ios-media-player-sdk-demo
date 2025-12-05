//
//  ViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/16.
//

#import "PLVEntranceViewController.h"
#import "PLVDemoVideoFeedViewController.h"
#import "PLVDemoVodMediaViewController.h"
#import "PLVDownloadCenterViewController.h"
#import "PLVDemoVodCourseViewController.h"
#import "AppDelegate.h"

// 依赖库
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

#define PushOrModel 1 // 进入页面方式（1-push、0-model）

@interface PLVEntranceViewController ()

@property (nonatomic, strong) UIButton *shortVideoButton; // 短视频
@property (nonatomic, strong) UIButton *watchButton; // 长视频
@property (nonatomic, strong) UIButton *cacheVideo; // 视频缓存

@end

@implementation PLVEntranceViewController

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];
    
    [self.view addSubview:self.shortVideoButton];
    [self.view addSubview:self.watchButton];
    [self.view addSubview:self.cacheVideo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark setupUI
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    NSInteger buttonCount = 3;
    CGFloat buttonWidth = 212.0;
    CGFloat buttonHeight = 108.0;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat originX = (viewWidth - buttonWidth) / 2.0;
    CGFloat originY = (viewHeight - (buttonHeight + 16) * buttonCount) / 2.0;
    self.shortVideoButton.frame = CGRectMake(originX, originY, buttonWidth, buttonHeight);
    originY += (buttonHeight + 20);
    self.watchButton.frame = CGRectMake(originX, originY, buttonWidth, buttonHeight);
    originY += (buttonHeight + 20);
    self.cacheVideo.frame = CGRectMake(originX, originY, buttonWidth, buttonHeight);
}

- (UIButton *)shortVideoButton {
    if (!_shortVideoButton) {
        _shortVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shortVideoButton setBackgroundImage:[UIImage imageNamed:@"short_video_profile"] forState:UIControlStateNormal];
        [_shortVideoButton addTarget:self action:@selector(shortVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shortVideoButton;
}

- (UIButton *)watchButton {
    if (!_watchButton) {
        _watchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_watchButton setBackgroundImage:[UIImage imageNamed:@"long_video_profile"] forState:UIControlStateNormal];
        [_watchButton addTarget:self action:@selector(watchVodButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _watchButton;
}

- (UIButton *)cacheVideo{
    if (!_cacheVideo) {
        _cacheVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cacheVideo setBackgroundImage:[UIImage imageNamed:@"download_video_profile"] forState:UIControlStateNormal];
        [_cacheVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cacheVideo.titleLabel.font = [UIFont systemFontOfSize:18];
        _cacheVideo.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_cacheVideo addTarget:self action:@selector(cacheVideoButton:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cacheVideo;
}

// 短视频
- (void)shortVideoButtonAction:(id)sender {
    PLVDemoVideoFeedViewController *vctrl = [[PLVDemoVideoFeedViewController alloc] init];
    if (PushOrModel) {
        vctrl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vctrl animated:YES];
    }else{
        vctrl.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vctrl animated:YES completion:nil];
    }
}

// 长视频观看
- (void)watchVodButtonAction:(id)sender {
    //PLVDemoVodMediaViewController *vodMediaVC = [[PLVDemoVodMediaViewController alloc] init];
    PLVDemoVodCourseViewController *vodMediaVC = [[PLVDemoVodCourseViewController alloc] init];

    if (PushOrModel) {
        vodMediaVC.hidesBottomBarWhenPushed = YES;
        // 公共账号
        vodMediaVC.vid = @"e97dbe3e648aefc2eb6f68b96db9db6c_e"; //

        if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive &&
            [[PLVMediaPlayerPictureInPictureManager sharedInstance].currentPlaybackVid isEqualToString:vodMediaVC.vid]) {
            [[PLVMediaPlayerPictureInPictureManager sharedInstance] stopPictureInPicture];
        }
        else{
            [self.navigationController pushViewController:vodMediaVC animated:YES];
        }
    }else{
        vodMediaVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vodMediaVC animated:YES completion:nil];
    }
}

- (void)cacheVideoButton:(UIButton *)button{
    PLVDownloadCenterViewController *centerVC = [[PLVDownloadCenterViewController alloc] init];
    if (PushOrModel) {
        centerVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:centerVC animated:YES];
    }else{
        centerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:centerVC animated:YES completion:nil];
    }
}

@end

