//
//  PLVMediaPlayerSkinOutMoreView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import "PLVMediaPlayerSkinOutMoreView.h"
#import "UIImage+Tint.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaPlayerSkinOutMoreView()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIButton *audioModeBtn;
@property (nonatomic, strong) UIButton *picInPicBtn;

@property (nonatomic, strong) UILabel *qualityLbl;
@property (nonatomic, strong) UIButton *lowQualityBtn;
@property (nonatomic, strong) UIButton *midQualityBtn;
@property (nonatomic, strong) UIButton *highQualtiyBtn;

@property (nonatomic, strong) UILabel *playRateLbl;
@property (nonatomic, strong) UIButton *playRate1Btn; // 0.5
@property (nonatomic, strong) UIButton *playRate2Btn; // 1
@property (nonatomic, strong) UIButton *playRate3Btn; // 1.5
@property (nonatomic, strong) UIButton *playRate4Btn; // 2


@end

@implementation PLVMediaPlayerSkinOutMoreView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (instancetype)init{
    if (self = [super initWithFrame:CGRectZero]){
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    [self addSubview:self.bgView];
    [self addSubview:self.contentView];
    
    // close
    [self.contentView addSubview:self.closeBtn];
    
    // audio model
    [self.contentView addSubview:self.audioModeBtn];
    // pic in pic
    [self.contentView addSubview:self.picInPicBtn];
    
    // quality
    [self.contentView addSubview:self.qualityLbl];
    [self.contentView addSubview:self.lowQualityBtn];
    [self.contentView addSubview:self.midQualityBtn];
    [self.contentView addSubview:self.highQualtiyBtn];
    
    // rate
    [self.contentView addSubview:self.playRateLbl];
    [self.contentView addSubview:self.playRate1Btn];
    [self.contentView addSubview:self.playRate2Btn];
    [self.contentView addSubview:self.playRate3Btn];
    [self.contentView addSubview:self.playRate4Btn];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.bgView addGestureRecognizer:tapGes];
}

- (void)updateUI{
    self.bgView.frame = self.bounds;
    NSInteger content_height = 240;
    if (self.audioModeBtn.hidden && self.picInPicBtn.hidden){
        content_height = 160;
    }
    self.contentView.frame = CGRectMake(0, self.bounds.size.height - content_height, self.bounds.size.width, content_height);
    
    CGFloat topInset = 48.0;
    CGFloat leftInset = 24;
    CGFloat righInset = 20.0;
    CGFloat closeTop = 20;
    self.closeBtn.frame = CGRectMake(self.bounds.size.width - 24 - righInset, closeTop, 24, 24);
    
    // 音频
    CGPoint origin = CGPointMake(leftInset, topInset);
    self.audioModeBtn.frame = CGRectMake(origin.x, origin.y, 60, 60);
    
    // 小窗
    CGFloat offset_x = CGRectGetMaxX(self.audioModeBtn.frame) + 30;
    if (self.audioModeBtn.hidden)
        offset_x = leftInset;
    origin = CGPointMake(offset_x, origin.y);
    self.picInPicBtn.frame = CGRectMake(origin.x, origin.y, 60, 60);
    
    CGFloat start_y = CGRectGetMaxY(self.audioModeBtn.frame);
    if (self.audioModeBtn.hidden && self.picInPicBtn.hidden){
        start_y = CGRectGetMinY(self.audioModeBtn.frame);
    }
    origin = CGPointMake(leftInset + 4, start_y + 28);
    self.qualityLbl.frame = CGRectMake(origin.x, origin.y, 60, 20);
    origin = CGPointMake(CGRectGetMaxX(self.qualityLbl.frame) + 20, origin.y);
    self.lowQualityBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    origin = CGPointMake(CGRectGetMaxX(self.lowQualityBtn.frame) + 20, origin.y);
    self.midQualityBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    origin = CGPointMake(CGRectGetMaxX(self.midQualityBtn.frame) + 20, origin.y);
    self.highQualtiyBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    
    start_y = CGRectGetMaxY(self.qualityLbl.frame);
    if (self.qualityLbl.hidden){
        start_y = CGRectGetMinY(self.qualityLbl.frame);
    }
    origin = CGPointMake(leftInset + 4, start_y + 12);
    self.playRateLbl.frame = CGRectMake(origin.x, origin.y, 60, 20);
    origin = CGPointMake(CGRectGetMaxX(self.playRateLbl.frame) + 20, origin.y);
    self.playRate1Btn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    origin = CGPointMake(CGRectGetMaxX(self.playRate1Btn.frame) + 20, origin.y);
    self.playRate2Btn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    origin = CGPointMake(CGRectGetMaxX(self.playRate2Btn.frame) + 20, origin.y);
    self.playRate3Btn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    origin = CGPointMake(CGRectGetMaxX(self.playRate3Btn.frame) + 20, origin.y);
    self.playRate4Btn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    
    [self drawCorners];
}

- (void)drawCorners{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;

    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds
                                           byRoundingCorners:corners
                                                 cornerRadii:CGSizeMake(20, 20)].CGPath;
    self.contentView.layer.mask = maskLayer;
}

- (UIView *)bgView{
    if (!_bgView){
        _bgView = [[UIView alloc] init];
        _bgView.alpha = 0.9;
    }
    
    return _bgView;
}

- (UIView *)contentView{
    if (!_contentView){
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return _contentView;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"plv_skin_menu_icon_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeBtn;
}

- (UIButton *)audioModeBtn{
    if (!_audioModeBtn){
        _audioModeBtn = [self buttonWithTitle:@"音频模式" tag:0];
        [_audioModeBtn addTarget:self action:@selector(audioModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *selImg = [UIImage imageNamed:@"plv_skin_menu_audio_mode"];
        UIImage *defaultImg = [selImg imageWithCustomTintColor:[PLVVodColorUtil colorFromHexString:@"#333333"]];
        [_audioModeBtn setImage:defaultImg forState:UIControlStateNormal];
        [_audioModeBtn setImage:selImg forState:UIControlStateSelected];
        
        [self layoutButtonWithEdgeInsetsStyle:1 imageTitleSpace:1 button:_audioModeBtn];
    }
    
    return _audioModeBtn;
}

- (UIButton *)picInPicBtn{
    if (!_picInPicBtn){
        _picInPicBtn = [self buttonWithTitle:@"小窗播放" tag:0];
        [_picInPicBtn addTarget:self action:@selector(picInPicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *defaultImg = [UIImage imageNamed:@"plv_skin_menu_icon_picinpic"];
        UIImage *selImg = [defaultImg imageWithCustomTintColor:[PLVVodColorUtil colorFromHexString:@"#3F76FC"]];
        [_picInPicBtn setImage:defaultImg forState:UIControlStateNormal];
        [_picInPicBtn setImage:selImg forState:UIControlStateSelected];
        
        [self layoutButtonWithEdgeInsetsStyle:1 imageTitleSpace:1 button:_picInPicBtn];
    }
    
    return _picInPicBtn;
}

- (UILabel *)qualityLbl{
    if (!_qualityLbl){
        _qualityLbl = [[UILabel alloc] init];
        _qualityLbl.text = @"清晰度:";
        _qualityLbl.font = [UIFont systemFontOfSize:12];
        _qualityLbl.textColor = [PLVVodColorUtil colorFromHexString:@"#333333"];
    }
    
    return _qualityLbl;
}

- (UIButton *)lowQualityBtn{
    if (!_lowQualityBtn){
        _lowQualityBtn = [self buttonWithTitle:@"流畅" tag:1];
        [_lowQualityBtn addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _lowQualityBtn;
}

- (UIButton *)midQualityBtn{
    if (!_midQualityBtn){
        _midQualityBtn = [self buttonWithTitle:@"高清" tag:2];
        [_midQualityBtn addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _midQualityBtn;
}

- (UIButton *)highQualtiyBtn{
    if (!_highQualtiyBtn){
        _highQualtiyBtn = [self buttonWithTitle:@"超清" tag:3];
        [_highQualtiyBtn addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _highQualtiyBtn;
}

- (UILabel *)playRateLbl{
    if (!_playRateLbl){
        _playRateLbl = [[UILabel alloc] init];
        _playRateLbl.text = @"倍速:";
        _playRateLbl.font = [UIFont systemFontOfSize:12];
        _playRateLbl.textColor = [PLVVodColorUtil colorFromHexString:@"#333333"];
    }
    
    return _playRateLbl;
}

- (UIButton *)playRate1Btn{
    if (!_playRate1Btn){
        _playRate1Btn = [self buttonWithTitle:@"0.5x" tag:1];
        [_playRate1Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate1Btn;
}

- (UIButton *)playRate2Btn{
    if (!_playRate2Btn){
        _playRate2Btn = [self buttonWithTitle:@"1.0x" tag:2];
        [_playRate2Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate2Btn;
}

- (UIButton *)playRate3Btn{
    if (!_playRate3Btn){
        _playRate3Btn = [self buttonWithTitle:@"1.5x" tag:3];
        [_playRate3Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate3Btn;
}

- (UIButton *)playRate4Btn{
    if (!_playRate4Btn){
        _playRate4Btn = [self buttonWithTitle:@"2.0x" tag:4];
        [_playRate4Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate4Btn;
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger )tag{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[PLVVodColorUtil colorFromHexString:@"#333333"] forState:UIControlStateNormal];
    [button setTitleColor:[PLVVodColorUtil colorFromHexString:@"#3F76FC"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.tag = tag;
    
    return button;
}

#pragma mark button action
- (void)closeButtonClick:(UIButton *)closeButton{
    [self hideMoreView];
}

- (void)audioModeButtonClick:(UIButton *)audioButton{
    [self hideMoreView];
    if (audioButton.selected)
        return;
    
    _mediaPlayerState.curPlayMode = 2;

    audioButton.selected = !audioButton.selected;
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_SwitchToAudioMode)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_SwitchToAudioMode];
    }
}

- (void)picInPicButtonClick:(UIButton *)picInPicButton{
    [self hideMoreView];
//    if (picInPicButton.selected)
//        return;
    
    _mediaPlayerState.curWindowMode = 2;

    picInPicButton.selected = !picInPicButton.selected;
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_StartPictureInPicture)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_StartPictureInPicture];
    }
}

- (void)qualityButtonClick:(UIButton *)qualityButton{
    [self hideMoreView];
    if (qualityButton.selected)
        return;
    
    NSInteger qualityLevel = qualityButton.tag;
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_SwitchQualityLevel:)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_SwitchQualityLevel:qualityLevel];
    }
    
    _mediaPlayerState.curQualityLevel = qualityLevel;
}

- (void)playRateButtonClick:(UIButton *)playRateButton{
    [self hideMoreView];

    if (playRateButton.selected)
        return;
    
    playRateButton.selected = !playRateButton.selected;
    NSInteger index = playRateButton.tag;
    CGFloat rate = index/2.0;
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_SwitchPlayRate:)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_SwitchPlayRate:rate];
    }
    
    _mediaPlayerState.curPlayRate = rate;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    [self hideMoreView];
}

#pragma mark private
- (void)setMediaPlayerState:(PLVMediaPlayerState *)mediaPlayerState{
    _mediaPlayerState = mediaPlayerState;
    
    // 当前清晰度
    if (self.mediaPlayerState.curPlayMode == 1 && mediaPlayerState.qualityCount > 1){
        // 视频模式
        self.lowQualityBtn.selected = NO;
        self.midQualityBtn.selected = NO;
        self.highQualtiyBtn.selected = NO;
        
        self.lowQualityBtn.hidden = NO;
        self.midQualityBtn.hidden = NO;
        self.highQualtiyBtn.hidden = NO;
        self.qualityLbl.hidden = NO;
        switch (mediaPlayerState.curQualityLevel) {
            case 1:
                self.lowQualityBtn.selected = YES;
                break;
            case 2:
                self.midQualityBtn.selected = YES;
                break;
            case 3:
                self.highQualtiyBtn.selected = YES;
                break;
            default:
                break;
        }
    }
    else{
        // 当前音频模式播放
        self.lowQualityBtn.hidden = YES;
        self.midQualityBtn.hidden = YES;
        self.highQualtiyBtn.hidden = YES;
        self.qualityLbl.hidden = YES;
    }
  
    // 当前倍速
    self.playRate1Btn.selected = NO;
    self.playRate2Btn.selected = NO;
    self.playRate3Btn.selected = NO;
    self.playRate4Btn.selected = NO;
    NSInteger playrate = mediaPlayerState.curPlayRate *2;
    switch (playrate) {
        case 1:
            self.playRate1Btn.selected = YES;
            break;
        case 2:
            self.playRate2Btn.selected = YES;
            break;
        case 3:
            self.playRate3Btn.selected = YES;
            break;
        case 4:
            self.playRate4Btn.selected = YES;
            break;
            
        default:
            break;
    }
    
    self.audioModeBtn.hidden = !mediaPlayerState.isSupportAudioMode;
    self.audioModeBtn.selected = mediaPlayerState.curPlayMode == 2 ? YES:NO;
    
    self.picInPicBtn.hidden = !mediaPlayerState.isSupportWindowMode;
    self.picInPicBtn.selected = mediaPlayerState.curWindowMode == 2 ? YES:NO;
}

#pragma mark public
- (void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState{
    self.hidden = NO;
    self.mediaPlayerState = mediaPlayerState;
    
    [self updateUI];
}

- (void)showMoreView{
    [self showMoreViewWithModel:self.mediaPlayerState];
}

- (void)hideMoreView{
    self.hidden = YES;
}

- (void)layoutButtonWithEdgeInsetsStyle:(NSInteger)style
                        imageTitleSpace:(CGFloat)space
                                 button:(UIButton *)button{
    // 1. 得到imageView和titleLabel的宽、高
    //    CGFloat imageWith = self.imageView.frame.size.width;
    //    CGFloat imageHeight = self.imageView.frame.size.height;
    CGFloat imageWith = button.currentImage.size.width;
    CGFloat imageHeight = button.currentImage.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = button.titleLabel.intrinsicContentSize.width;
        labelHeight = button.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = button.titleLabel.frame.size.width;
        labelHeight = button.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
        case 1: { // top
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space, 0);
        }
            break;
        case 2: { // left
            imageEdgeInsets = UIEdgeInsetsMake(0, -space, 0, space);
            labelEdgeInsets = UIEdgeInsetsMake(0, space, 0, -space);
        }
            break;
        case 3: { // botton
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space, -imageWith, 0, 0);
        }
            break;
        case 4: { // right
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space, 0, -labelWidth-space);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space, 0, imageWith+space);
        }
            break;
        default:
            break;
    }
    // 4. 赋值
    button.titleEdgeInsets = labelEdgeInsets;
    button.imageEdgeInsets = imageEdgeInsets;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
