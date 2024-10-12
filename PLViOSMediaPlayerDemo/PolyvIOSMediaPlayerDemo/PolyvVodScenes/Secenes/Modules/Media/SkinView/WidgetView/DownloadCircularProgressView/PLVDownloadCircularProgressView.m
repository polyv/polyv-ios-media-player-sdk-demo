//
//  PLVDownloadCircularProgressView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import "PLVDownloadCircularProgressView.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

@interface PLVDownloadCircularProgressView ()

@end

@implementation PLVDownloadCircularProgressView

#pragma mark [life cycle]

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
        [self updateUI];
    }
    
    return self;
}

- (void)setupUI{
    
    [self addSubview:self.statusLable];
    [self addSubview:self.progressView];
    [self addSubview:self.startDownload];
    
    // 添加单击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                 action:@selector(tapGestureAction:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.progressView addGestureRecognizer:tapGesture];
}

- (void)updateUI{
    // 48x58
    CGSize btn_size = CGSizeMake(32, 32);
    CGFloat start_x = (self.bounds.size.width - btn_size.width)/2;
    CGFloat start_y = 5;
    self.startDownload.frame = CGRectMake(start_x, start_y, btn_size.width, btn_size.height);
    
    start_x = 0;
    start_y = self.bounds.size.height - 18 - 4;
    self.statusLable.frame = CGRectMake(start_x, start_y, self.bounds.size.width, 18);
    
    // 进度控件
    self.progressView.frame = self.startDownload.frame;
}

#pragma mark [ getter]
- (PLVCircularProgressView *)progressView{
    if (!_progressView){
        _progressView = [[PLVCircularProgressView alloc] initWithFrame:self.bounds andProgress:0];
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (UILabel *)statusLable{
    if (!_statusLable){
        _statusLable = [[UILabel alloc] init];
        _statusLable.font = [UIFont systemFontOfSize:12];
        _statusLable.textAlignment = NSTextAlignmentCenter;
        _statusLable.textColor = [UIColor blackColor];
        _statusLable.text = @"下载";
    }
    return _statusLable;
}

- (UIButton *)startDownload{
    if (!_startDownload){
        _startDownload = [[UIButton alloc] init];
        [_startDownload setImage:[UIImage imageNamed:@"plv_skin_menu_download"] forState:UIControlStateNormal];
        [_startDownload addTarget:self action:@selector(startDownloadButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _startDownload;
}

#pragma mark [action]
- (void)startDownloadButton:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularProgressView_startDownload:)]){
        [self.delegate circularProgressView_startDownload:self];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture{
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularProgressView_startDownload:)]){
        [self.delegate circularProgressView_startDownload:self];
    }
}

#pragma mark [public]

- (void)updateDownloadState:(PLVVodDownloadState)downloadState{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (downloadState) {
            case PLVVodDownloadStatePreparing:
            case PLVVodDownloadStatePreparingTask:
            case PLVVodDownloadStateReady:
            case PLVVodDownloadStateStopping:
            case PLVVodDownloadStateStopped:{
                self.statusLable.text = @"等待中";
                self.startDownload.hidden = NO;
                self.progressView.hidden = YES;

            } break;
            case PLVVodDownloadStateRunning:{
                self.statusLable.text = @"下载中";
                self.startDownload.hidden = YES;
                self.progressView.hidden = NO;

            } break;
            case PLVVodDownloadStateSuccess:{
                self.statusLable.text = @"已下载";
                self.startDownload.hidden = NO;
                self.progressView.hidden = YES;

            } break;
            case PLVVodDownloadStateFailed:{
                self.statusLable.text = @"下载失败";
                self.startDownload.hidden = NO;
                self.progressView.hidden = YES;

            } break;
        }
    });
}

- (void)resetProgressView{
    self.statusLable.text = @"下载";
    self.startDownload.hidden = NO;
    self.progressView.hidden = YES;
}

@end
