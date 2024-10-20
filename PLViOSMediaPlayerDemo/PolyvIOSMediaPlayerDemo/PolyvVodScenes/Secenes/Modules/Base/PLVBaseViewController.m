//
//  PLVBaseViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/17.
//

#import "PLVBaseViewController.h"
#import "PLVSecureView.h"
#import <AVFAudio/AVFAudio.h>

@interface PLVBaseViewController ()

@end

@implementation PLVBaseViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置系统录屏防护
    [self configVideoCaptureProtect:self.sysScreenRecordProtect];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 未监听到录屏通知 处理录屏状态
    [self screenCapturedEventWithNoti:nil];
}

- (void)configVideoCaptureProtect:(BOOL)videoCapturePretect{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    if (videoCapturePretect){
        if ([UIDevice currentDevice].systemVersion.integerValue >= 11) {
            // iOS 11以上
            [self screenCapturedEventWithNoti:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                    selector:@selector(screenCapturedEventWithNoti:)
                                                        name:UIScreenCapturedDidChangeNotification
                                                      object:nil];
        }else{                        // iOS 11以下
            [self audioSessionRouteChangeWithNoti:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                    selector:@selector(audioSessionRouteChangeWithNoti:)
                                                        name:AVAudioSessionRouteChangeNotification
                                                      object:nil];
        }
    }
#pragma clang diagnostic pop
}


- (void)screenCapturedEventWithNoti:(NSNotification *)noti{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    if (self.sysScreenRecordProtect){
        UIScreen * sc = [UIScreen mainScreen];
        if ([UIDevice currentDevice].systemVersion.integerValue >= 11) {
            if (sc.isCaptured) {
                [self startPreventScreenCapture];
            }else{
                [self stopPreventScreenCapture];
            }
        }
    }
#pragma clang diagnostic pop
}

- (void)audioSessionRouteChangeWithNoti:(NSNotification *)noti{
    AVAudioSessionRouteDescription * routeDes = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription * subDes in routeDes.outputs) {
        if ([subDes.portType isEqualToString:AVAudioSessionPortAirPlay] ||
            [subDes.portType isEqualToString:@"AirPlay"]) {
            [self startPreventScreenCapture];
            
        }else if ([subDes.portType isEqualToString:AVAudioSessionPortHDMI] ||
                  [subDes.portType isEqualToString:@"HDMIOutput"]) {
            [self startPreventScreenCapture];
            
        }else if([subDes.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker] ||
                 [subDes.portType isEqualToString:@"Speaker"]){
            [self stopPreventScreenCapture];
        }
    }
}

- (void)startPreventScreenCapture{
    // 此时播放器是否播放中
    self.view.hidden = YES;
    
    // 提示消息
    [self showVideoProtectMessage];
    
    // 暂停播放 并且保存播放状态
    // 子类实现相关逻辑
}

- (void)stopPreventScreenCapture{
    // 修改为'非正被录屏'状态
    self.view.hidden = NO;
    
    // 若原先处于播放中状态，则恢复播放
    // 子类实现相关逻辑
    if (self.isPlayingWhenCaptureStart) {
    }
}

- (void)showVideoProtectMessage{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"视频暂时无法播放"
                                                                              message:@"停止录屏或投屏操作才能继续播放视频"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:^{}];
    }]];
    [self presentViewController:alertController animated:YES completion:^{

    }];
}


@end
