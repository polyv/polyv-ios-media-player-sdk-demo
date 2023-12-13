//
//  ViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/16.
//

#import "PLVEntranceViewController.h"
#import "PLVDemoVideoFeedViewController.h"
#import "PLVDemoVodMediaViewController.h"
#import "AppDelegate.h"

// 依赖库
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import <PLVIJKPlayer/PLVIJKPlayer.h>

#define PushOrModel 1 // 进入页面方式（1-push、0-model）

@interface PLVEntranceViewController ()

@property (nonatomic, strong) UIButton *watchButton;
@property (nonatomic, strong) UIButton *shortVideoButton;
@property (nonatomic, strong) UIButton *bankShortVideo;

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
        
    [PLVIJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
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
    
    NSInteger buttonCount = 2;
    CGFloat buttonWidth = 212.0;
    CGFloat buttonHeight = 108.0;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat originX = (viewWidth - buttonWidth) / 2.0;
    CGFloat originY = (viewHeight - (buttonHeight - 16) * buttonCount) / 2.0;
    self.shortVideoButton.frame = CGRectMake(originX, originY, buttonWidth, buttonHeight);
    originY += (buttonHeight + 20);
    self.watchButton.frame = CGRectMake(originX, originY, buttonWidth, buttonHeight);
    originY += (buttonHeight + 20);
    self.bankShortVideo.frame = CGRectMake(originX, originY, buttonWidth, buttonHeight);
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

- (UIButton *)bankShortVideo{
    if (!_bankShortVideo) {
        _bankShortVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bankShortVideo setTitle:@"宁行短视频" forState:UIControlStateNormal];
        [_bankShortVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bankShortVideo setBackgroundColor:[UIColor blackColor]];
        _bankShortVideo.titleLabel.font = [UIFont systemFontOfSize:24];
        _bankShortVideo.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_bankShortVideo addTarget:self action:@selector(bankShortVideoButton:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _bankShortVideo;
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
    PLVDemoVodMediaViewController *vodMediaVC = [[PLVDemoVodMediaViewController alloc] init];
    if (PushOrModel) {
        vodMediaVC.hidesBottomBarWhenPushed = YES;
        vodMediaVC.vid = @"e97dbe3e648aefc2eb6f68b96db9db6c_e"; //
        [self.navigationController pushViewController:vodMediaVC animated:YES];
    }else{
        vodMediaVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vodMediaVC animated:YES completion:nil];
    }
}

- (void)bankShortVideoButton:(UIButton *)button{
//    PLVShortVideoMediaPlayerVC *simpleVC = [[PLVShortVideoMediaPlayerVC alloc] init];
//    if (PushOrModel) {
//        [self.navigationController pushViewController:simpleVC animated:YES];
//    }else{
//        simpleVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:simpleVC animated:YES completion:nil];
//    }
}


@end

