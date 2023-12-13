//
//  PLVMediaPlayerSkinAudioModeView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import "PLVMediaPlayerSkinAudioModeView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "UIImage+Tint.h"
#import "PLVOrientationUtil.h"

@interface PLVMediaPlayerSkinAudioModeView()

@property (nonatomic, strong) UIImageView *backgroudImgView;   // 视图背景
@property (nonatomic, strong) UIImageView *audioCoverImage;    // 封面图
@property (nonatomic, strong) UIImageView *audioCoverBackImg;  // 封面底图
@property (nonatomic, strong) UIImageView *audioBarImageView;  // 音频动态条

@property (nonatomic, strong) UILabel *playTipsLable; // 在锁屏和切到后台时也能播放音频

@end

@implementation PLVMediaPlayerSkinAudioModeView

- (instancetype)init{
    if (self = [super initWithFrame:CGRectZero]){
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)setupUI{
    self.clipsToBounds = YES;

    [self addSubview:self.backgroudImgView];
    [self addSubview:self.audioCoverBackImg];
    [self.audioCoverBackImg addSubview:self.audioCoverImage];
    
    [self addSubview:self.playTipsLable];
    [self addSubview:self.audioBarImageView];
    [self addSubview:self.switchButton];
    
    self.audioCoverImage.layer.masksToBounds = YES;
    self.audioCoverImage.contentMode = UIViewContentModeScaleAspectFill;

    self.audioCoverBackImg.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroudImgView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)updateUI{
    self.backgroudImgView.frame = self.bounds;
    BOOL isLandscape = [PLVOrientationUtil isLandscape];
    
    if (isLandscape){ // 横向
        CGFloat leftPad = 220;
        CGFloat topPad = 128;
        CGPoint origin = CGPointMake(leftPad, topPad);
        self.audioCoverBackImg.frame = CGRectMake(origin.x, origin.y, 120, 120);
        self.audioCoverBackImg.image = [UIImage imageNamed:@"plv_skin_control_icon_audiomodel_landscape_back"];
        self.audioCoverImage.frame = CGRectMake(25, 25, 70, 70);
        self.audioCoverImage.layer.cornerRadius = 35;
        
        origin.x = CGRectGetMaxX(self.audioCoverBackImg.frame) + 20;
        self.playTipsLable.frame = CGRectMake(origin.x, origin.y, self.bounds.size.width - origin.x - 20, 20);
        
        origin.x = CGRectGetMaxX(self.audioCoverBackImg.frame) + 20;
        origin.y = CGRectGetMaxY(self.playTipsLable.frame) + 5;
        self.audioBarImageView.frame = CGRectMake(origin.x, origin.y, 188, 20);
        
        origin.x = CGRectGetMaxX(self.audioCoverBackImg.frame) + 64;
        origin.y = CGRectGetMaxY(self.audioCoverBackImg.frame) - 25;
        self.switchButton.frame = CGRectMake(origin.x, origin.y, 100, 20);
    } else { // 竖向
        CGFloat leftPad = 44;
        CGFloat topPad = 62;
        CGPoint origin = CGPointMake(leftPad, topPad);
        self.audioCoverBackImg.frame = CGRectMake(origin.x, origin.y, 88, 88);
        self.audioCoverBackImg.image = [UIImage imageNamed:@"plv_skin_control_icon_audiomodel_portrait_back"];

        self.audioCoverImage.frame = CGRectMake(18, 18, 52, 52);
        self.audioCoverImage.layer.cornerRadius = 52/2;
        
        origin.x = CGRectGetMaxX(self.audioCoverBackImg.frame) + 20;
        self.playTipsLable.frame = CGRectMake(origin.x, origin.y, self.bounds.size.width - origin.x - 20, 20);
        
        origin.x = CGRectGetMaxX(self.audioCoverBackImg.frame) + 20;
        origin.y = CGRectGetMaxY(self.playTipsLable.frame) + 5;
        self.audioBarImageView.frame = CGRectMake(origin.x, origin.y, self.bounds.size.width - origin.x - 20, 20);
        
        origin.x = CGRectGetMaxX(self.audioCoverBackImg.frame) + 64;
        origin.y = CGRectGetMaxY(self.audioCoverBackImg.frame) - 25;
        self.switchButton.frame = CGRectMake(origin.x, origin.y, 100, 20);
    }
}

- (void)setMediaPlayerState:(PLVMediaPlayerState *)mediaPlayerState{
    _mediaPlayerState = mediaPlayerState;
    
    [self setCoverUrl:mediaPlayerState.snapshot];
}

- (void)setCoverUrl:(NSString *)url {
    [self.audioCoverImage sd_setImageWithURL:[NSURL URLWithString:url]];
}

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    if (mode == PLVVodPlaybackModeAudio) {
//        self.audioCoverContainerView.hidden = NO;
    } else {
//        self.audioCoverContainerView.hidden = YES;
    }
}

- (void)hiddenContainerView:(BOOL)hidden {
//    self.audioCoverContainerView.hidden = hidden;
}

- (void)setAniViewCornerRadius:(CGFloat)cornerRadius{
    self.audioCoverImage.layer.cornerRadius = cornerRadius;
    
    self.audioCoverImage.frame = CGRectMake(0, 0, 2 * cornerRadius, 2 * cornerRadius);
    self.audioCoverImage.center = CGPointMake(80, 80);
    
    CGFloat backImgWidth = 2 * cornerRadius + (cornerRadius <= 30 ? 20 : 40);
    self.audioCoverBackImg.frame = CGRectMake(0, 0, backImgWidth, backImgWidth);
    self.audioCoverBackImg.center = CGPointMake(80, 80);
}

- (void)startRotate {
    if ([self.audioCoverImage.layer.animationKeys count] == 0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.beginTime = CACurrentMediaTime();
        animation.duration = 30;
        animation.repeatCount = HUGE_VALF;
        animation.fromValue = @(0.0);
        animation.toValue = @(2 * M_PI);
        animation.removedOnCompletion = NO;
        [self.audioCoverImage.layer addAnimation:animation forKey:@"rotate"];
    }
}

- (void)stopRotate {
    if ([self.audioCoverImage.layer.animationKeys count] != 0) {
        [self.audioCoverImage.layer removeAllAnimations];
    }
}

- (UIImageView *)backgroudImgView{
    if (!_backgroudImgView){
        _backgroudImgView = [[UIImageView alloc] init];
        _backgroudImgView.backgroundColor = [PLVVodColorUtil colorFromHexString:@"#3F76FC" alpha:0.2];
    }
    
    return _backgroudImgView;
}

- (UIImageView *)audioCoverImage{
    if(!_audioCoverImage){
        _audioCoverImage = [[UIImageView alloc] init];
    }
    
    return _audioCoverImage;
}

- (UIImageView *)audioCoverBackImg{
    if(!_audioCoverBackImg){
        _audioCoverBackImg = [[UIImageView alloc] init];
    }
    
    return _audioCoverBackImg;
}

- (UIImageView *)audioBarImageView{
    if (!_audioBarImageView){
        _audioBarImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"plv_skin_icon_audio_bar"];
        _audioBarImageView.image = image;
    }
    
    return _audioBarImageView;
}

- (UIButton *)switchButton{
    if (!_switchButton){
        _switchButton = [[UIButton alloc] init];
        [_switchButton setTitle:@"切回视频" forState:UIControlStateNormal];
        [_switchButton addTarget:self action:@selector(switchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _switchButton.titleLabel.font = [UIFont systemFontOfSize:10];
        _switchButton.backgroundColor = [UIColor colorWithRed:25/255.0 green:29/255.0 blue:42/255.0 alpha:1.0];
        _switchButton.layer.cornerRadius = 12;
    }
    
    return _switchButton;
}

- (UILabel *)playTipsLable{
    if (!_playTipsLable){
        _playTipsLable = [[UILabel alloc] init];
        _playTipsLable.text = @"在锁屏和切到后台时也能播放音频";
        _playTipsLable.font = [UIFont systemFontOfSize:12.0];
        _playTipsLable.textColor = [UIColor whiteColor];
    }
    
    return _playTipsLable;
}

#pragma mark 【Button Action】
- (void)switchButtonClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinAudioModeView_switchVideoMode:)]){
        [self.delegate mediaPlayerSkinAudioModeView_switchVideoMode:self];
    }
    
    _mediaPlayerState.curPlayMode = 1;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
