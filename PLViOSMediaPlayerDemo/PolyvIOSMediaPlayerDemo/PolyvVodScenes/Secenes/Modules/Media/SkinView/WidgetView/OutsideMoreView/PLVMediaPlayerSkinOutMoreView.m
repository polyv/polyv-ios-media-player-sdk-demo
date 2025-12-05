//
//  PLVMediaPlayerSkinOutMoreView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import "PLVMediaPlayerSkinOutMoreView.h"
#import "UIImage+PLVVodMediaTint.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerSkinSubtitleSetView.h"

@interface PLVMediaPlayerSkinOutMoreView()<
PLVMediaPlayerSkinSubtitleSetViewDelegate,
PLVDownloadCircularProgressViewDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIButton *audioModeBtn;
@property (nonatomic, strong) UIButton *picInPicBtn;
@property (nonatomic, strong) UIButton *subtitleSetBtn;

@property (nonatomic, strong) UILabel *qualityLbl;
@property (nonatomic, strong) UIButton *lowQualityBtn;
@property (nonatomic, strong) UIButton *midQualityBtn;
@property (nonatomic, strong) UIButton *highQualtiyBtn;

@property (nonatomic, strong) UILabel *playRateLbl;
@property (nonatomic, strong) NSArray<NSNumber *> *playbackRates;
@property (nonatomic, strong) NSMutableArray<UIButton *> *playRateButtons;
@property (nonatomic, strong) UIScrollView *playRateScrollView;

@property (nonatomic, strong) PLVMediaPlayerSkinSubtitleSetView *subtitleSetView;


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
    // subtitle set
    [self.contentView addSubview:self.subtitleSetBtn];
    // download
    [self.contentView addSubview:self.downloadProgressView];
    
    // quality
    [self.contentView addSubview:self.qualityLbl];
    [self.contentView addSubview:self.lowQualityBtn];
    [self.contentView addSubview:self.midQualityBtn];
    [self.contentView addSubview:self.highQualtiyBtn];
    
    // rate
    [self.contentView addSubview:self.playRateLbl];
    [self.contentView addSubview:self.playRateScrollView];
    [self setupPlaybackRateButtonsIfNeeded];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.bgView addGestureRecognizer:tapGes];
}

- (void)updateUI{
    self.bgView.frame = self.bounds;
    NSInteger content_height = 240;
    // 字幕按钮一直存在，无需以下判断
    //    if (self.audioModeBtn.hidden && self.picInPicBtn.hidden){
    //        content_height = 160;
    //    }
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
    
    // 字幕设置
    offset_x = leftInset;
    if (!self.picInPicBtn.hidden){
        offset_x = CGRectGetMaxX(self.picInPicBtn.frame) + 30;
    }
    else if (!self.audioModeBtn.hidden){
        offset_x = CGRectGetMaxX(self.audioModeBtn.frame) + 30;
    }
    origin = CGPointMake(offset_x, origin.y);
    self.subtitleSetBtn.frame = CGRectMake(origin.x, origin.y, 60, 60);
    
    // 下载
    offset_x = CGRectGetMaxX(self.subtitleSetBtn.frame) + 30;
    origin = CGPointMake(offset_x, origin.y);
    self.downloadProgressView.frame = CGRectMake(origin.x, origin.y, 60, 60);
    
    // 清晰度
    CGFloat start_y = CGRectGetMaxY(self.subtitleSetBtn.frame);
    origin = CGPointMake(leftInset + 4, start_y + 28);
    self.qualityLbl.frame = CGRectMake(origin.x, origin.y, 60, 20);
    origin = CGPointMake(CGRectGetMaxX(self.qualityLbl.frame) + 20, origin.y);
    self.lowQualityBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    if (self.mediaPlayerState.qualityCount == 2){
        // 高清
        origin = CGPointMake(CGRectGetMaxX(self.lowQualityBtn.frame) + 20, origin.y);
        self.midQualityBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    }
    else if (self.mediaPlayerState.qualityCount == 3){
        // 高清
        origin = CGPointMake(CGRectGetMaxX(self.lowQualityBtn.frame) + 20, origin.y);
        self.midQualityBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
        
        // 超清
        origin = CGPointMake(CGRectGetMaxX(self.midQualityBtn.frame) + 20, origin.y);
        self.highQualtiyBtn.frame = CGRectMake(origin.x, origin.y, 50, 20);
    }
    
    start_y = CGRectGetMaxY(self.qualityLbl.frame);
    if (self.qualityLbl.hidden){
        start_y = CGRectGetMinY(self.qualityLbl.frame);
    }
    origin = CGPointMake(leftInset + 4, start_y + 8);
    self.playRateLbl.frame = CGRectMake(origin.x, origin.y, 60, 20);
    // 滚动容器区域
    CGFloat scrollX = CGRectGetMaxX(self.playRateLbl.frame) + 12;
    CGFloat scrollW = self.bounds.size.width - scrollX - 20;
    CGFloat scrollH = 20;
    self.playRateScrollView.frame = CGRectMake(scrollX, origin.y, scrollW, scrollH);
    CGFloat buttonWidth = 48;
    CGFloat buttonHeight = 20;
    CGFloat spacing = 12;
    CGFloat contentX = 0;
    for (UIButton *button in self.playRateButtons){
        button.frame = CGRectMake(contentX, 0, buttonWidth, buttonHeight);
        contentX = CGRectGetMaxX(button.frame) + spacing;
    }
    self.playRateScrollView.contentSize = CGSizeMake(MAX(contentX - spacing, scrollW), scrollH);
    
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
        UIImage *defaultImg = [selImg imageWithCustomTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#333333"]];
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
        UIImage *selImg = [defaultImg imageWithCustomTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#3F76FC"]];
        [_picInPicBtn setImage:defaultImg forState:UIControlStateNormal];
        [_picInPicBtn setImage:selImg forState:UIControlStateSelected];
        
        [self layoutButtonWithEdgeInsetsStyle:1 imageTitleSpace:1 button:_picInPicBtn];
    }
    
    return _picInPicBtn;
}

- (UIButton *)subtitleSetBtn{
    if (!_subtitleSetBtn){
        _subtitleSetBtn = [self buttonWithTitle:@"字幕设置" tag:0];
        [_subtitleSetBtn addTarget:self action:@selector(subtitleSetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *selImg = [UIImage imageNamed:@"plv_skin_menu_setsubtitle_select"];
        UIImage *defaultImg =  [UIImage imageNamed:@"plv_skin_menu_setsubtitle"];
        [_subtitleSetBtn setImage:defaultImg forState:UIControlStateNormal];
        [_subtitleSetBtn setImage:selImg forState:UIControlStateSelected];
        
        [self layoutButtonWithEdgeInsetsStyle:1 imageTitleSpace:1 button:_subtitleSetBtn];
    }
    
    return _subtitleSetBtn;
}

- (UILabel *)qualityLbl{
    if (!_qualityLbl){
        _qualityLbl = [[UILabel alloc] init];
        _qualityLbl.text = @"清晰度:";
        _qualityLbl.font = [UIFont systemFontOfSize:12];
        _qualityLbl.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#333333"];
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
        _playRateLbl.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#333333"];
    }
    
    return _playRateLbl;
}

- (void)setupPlaybackRateButtonsIfNeeded{
    if (self.playRateButtons.count > 0){
        return;
    }
    // 配置可用倍速
    if (@available(iOS 15.0, *)) {
        self.playbackRates = @[@0.5, @0.75, @1.0, @1.25, @1.5, @2.0, @3.0];
    } else {
        self.playbackRates = @[@0.5, @0.75, @1.0, @1.25, @1.5, @2.0];
    }
    self.playRateButtons = [NSMutableArray array];
    NSInteger index = 0;
    for (NSNumber *rateNumber in self.playbackRates){
        CGFloat rate = rateNumber.floatValue;
        // 先到两位小数，再去掉多余末尾0，但至少保留一位小数
        NSString *rateString = [NSString stringWithFormat:@"%.2f", rate];
        while ([rateString hasSuffix:@"0"] && ![rateString hasSuffix:@".0"]) {
            rateString = [rateString substringToIndex:rateString.length - 1];
        }
        NSString *title = [NSString stringWithFormat:@"%@x", rateString];
        UIButton *button = [self buttonWithTitle:title tag:index];
        [button addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.playRateScrollView addSubview:button];
        [self.playRateButtons addObject:button];
        index++;
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger )tag{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[PLVVodMediaColorUtil colorFromHexString:@"#333333"] forState:UIControlStateNormal];
    [button setTitleColor:[PLVVodMediaColorUtil colorFromHexString:@"#3F76FC"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.tag = tag;
    
    return button;
}

- (PLVMediaPlayerSkinSubtitleSetView *)subtitleSetView{
    if (!_subtitleSetView){
        _subtitleSetView = [[PLVMediaPlayerSkinSubtitleSetView alloc] init];
        _subtitleSetView.delegate = self;
    }
    
    return _subtitleSetView;
}

- (PLVDownloadCircularProgressView *)downloadProgressView{
    if (!_downloadProgressView){
        _downloadProgressView = [[PLVDownloadCircularProgressView alloc] init];
        _downloadProgressView.delegate = self;
    }
    return _downloadProgressView;
    
}

#pragma mark button action
- (void)closeButtonClick:(UIButton *)closeButton{
    [self hideMoreView];
}

- (void)audioModeButtonClick:(UIButton *)audioButton{
    [self hideMoreView];
    audioButton.selected = !audioButton.selected;
    if (self.mediaPlayerState.curPlayMode == PLVMediaPlayerPlayModeAudio){
        self.mediaPlayerState.curPlayMode = PLVMediaPlayerPlayModeVideo;
    }
    else if (PLVMediaPlayerPlayModeVideo == self.mediaPlayerState.curPlayMode){
        self.mediaPlayerState.curPlayMode = PLVMediaPlayerPlayModeAudio;
    }
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_SwitchPlayMode:)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_SwitchPlayMode:self];
    }
}

- (void)picInPicButtonClick:(UIButton *)picInPicButton{
    [self hideMoreView];
//    if (picInPicButton.selected)
//        return;
    
    _mediaPlayerState.curWindowMode = PLVMediaPlayerWindowModePIP;

    picInPicButton.selected = !picInPicButton.selected;
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_StartPictureInPicture)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_StartPictureInPicture];
    }
}

- (void)subtitleSetButtonClick:(UIButton *)subtitleBtn{
//    [self hideMoreView];
    
    [self addSubview:self.subtitleSetView];
    self.subtitleSetView.frame = self.bounds;
    
    [self.subtitleSetView showWithConfigModel:self.mediaPlayerState.subtitleConfig];
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
    for (UIButton *btn in self.playRateButtons){
        btn.selected = NO;
    }
    playRateButton.selected = YES;
    NSInteger index = playRateButton.tag;
    if (index < 0 || index >= (NSInteger)self.playbackRates.count){
        return;
    }
    CGFloat rate = self.playbackRates[index].floatValue;
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
    [self setupPlaybackRateButtonsIfNeeded];
    for (UIButton *btn in self.playRateButtons){
        btn.selected = NO;
    }
    CGFloat target = mediaPlayerState.curPlayRate;
    NSInteger selIndex = 0;
    CGFloat minDiff = CGFLOAT_MAX;
    for (NSInteger i = 0; i < (NSInteger)self.playbackRates.count; i++){
        CGFloat r = self.playbackRates[i].floatValue;
        CGFloat diff = fabs(r - target);
        if (diff < minDiff){
            minDiff = diff;
            selIndex = i;
        }
    }
    if (selIndex >= 0 && selIndex < (NSInteger)self.playbackRates.count && selIndex < (NSInteger)self.playRateButtons.count){
        self.playRateButtons[selIndex].selected = YES;
    }
    
    self.audioModeBtn.hidden = !mediaPlayerState.isSupportAudioMode;
    self.audioModeBtn.selected = mediaPlayerState.curPlayMode == PLVMediaPlayerPlayModeAudio ? YES:NO;
    
    self.picInPicBtn.hidden = !mediaPlayerState.isSupportWindowMode;
    self.picInPicBtn.selected = mediaPlayerState.curWindowMode == PLVMediaPlayerWindowModePIP ? YES:NO;
    
    // subtitle
    self.subtitleSetBtn.selected = mediaPlayerState.subtitleConfig.subtitlesEnabled;
    
    // download
    self.downloadProgressView.hidden = self.mediaPlayerState.isOffPlayMode;
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

#pragma mark [PLVMediaPlayerSkinSubtitleSetViewDelegate]
- (void)mediaPlayerSkinSubtitleSetView_SelectSubtitle{
    // 刷新字幕
    self.subtitleSetBtn.selected = self.mediaPlayerState.subtitleConfig.subtitlesEnabled;
    
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_SetSubtitle)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_SetSubtitle];
    }
}

- (UIScrollView *)playRateScrollView{
    if (!_playRateScrollView){
        _playRateScrollView = [[UIScrollView alloc] init];
        _playRateScrollView.showsHorizontalScrollIndicator = NO;
        _playRateScrollView.showsVerticalScrollIndicator = NO;
        _playRateScrollView.bounces = YES;
        _playRateScrollView.alwaysBounceHorizontal = YES;
        _playRateScrollView.clipsToBounds = YES;
    }
    return _playRateScrollView;
}

#pragma mark [PLVDownloadCircularProgressViewDelegate]
/// 开始下载
- (void)circularProgressView_startDownload:(PLVDownloadCircularProgressView *)progressView{
    if (self.skinOutMoreViewDelegate && [self.skinOutMoreViewDelegate respondsToSelector:@selector(mediaPlayerSkinOutMoreView_StartDownload)]){
        [self.skinOutMoreViewDelegate mediaPlayerSkinOutMoreView_StartDownload];
    }
}

@end
