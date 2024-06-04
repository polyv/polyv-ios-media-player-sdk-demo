//
//  PLVMediaPlayerSkinMoreView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import "PLVMediaPlayerSkinMoreView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "UIImage+PLVVodMediaTint.h"

@interface PLVMediaPlayerSkinMoreView()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *audioModeBtn;
@property (nonatomic, strong) UIButton *picInPicBtn;
@property (nonatomic, strong) CAGradientLayer *bgLayer;

@end

@implementation PLVMediaPlayerSkinMoreView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    
    //
    [self.layer addSublayer:self.bgLayer];
    
    // close
    [self addSubview:self.closeBtn];
    
    // audio model
    [self addSubview:self.audioModeBtn];
    
    // pic in pic
    [self addSubview:self.picInPicBtn];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGes];
}

- (void)updateUI{
    CGFloat rightInset = 227;
    CGFloat topInset = 48;
    CGSize buttonSize = CGSizeMake(60, 60);
    
    self.bgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    self.closeBtn.frame = CGRectMake(self.bounds.size.width - 24 - 20, 20, 24, 24);
    
    CGPoint origin = CGPointMake(self.bounds.size.width - rightInset - buttonSize.width, topInset);
    self.picInPicBtn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
    
    origin = CGPointMake(CGRectGetMinX(self.picInPicBtn.frame)- 28 -buttonSize.width, origin.y);
    self.audioModeBtn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
}

- (CAGradientLayer *)bgLayer{
    if (!_bgLayer) {
        _bgLayer = [CAGradientLayer layer];
        _bgLayer.startPoint = CGPointMake(0.0, 0);
        _bgLayer.endPoint = CGPointMake(1, 0);
        _bgLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8].CGColor];
        _bgLayer.locations = @[@(0.0), @(1.0f)];
    }
    return _bgLayer;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = [[UIButton alloc] init];
        UIImage *origImg = [UIImage imageNamed:@"plv_skin_menu_icon_close"];
        [_closeBtn setImage:[origImg imageWithCustomTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeBtn;
}

- (UIButton *)audioModeBtn{
    if (!_audioModeBtn){
        _audioModeBtn = [self buttonWithTitle:@"音频模式" tag:0];
        [_audioModeBtn addTarget:self action:@selector(audioModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_audioModeBtn setTitleColor:[PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];

        UIImage *selImg = [UIImage imageNamed:@"plv_skin_menu_audio_mode"];
        UIImage *defaultImg = [selImg imageWithCustomTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF"]];
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
        [_picInPicBtn setTitleColor:[PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];

        UIImage *orig = [UIImage imageNamed:@"plv_skin_menu_icon_picinpic"];
        UIImage *defaultImg = [orig imageWithCustomTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#3FFFFFF"]];
        UIImage *selImg = [defaultImg imageWithCustomTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#3F76FC"]];
        [_picInPicBtn setImage:defaultImg forState:UIControlStateNormal];
        [_picInPicBtn setImage:selImg forState:UIControlStateSelected];
        
        [self layoutButtonWithEdgeInsetsStyle:1 imageTitleSpace:1 button:_picInPicBtn];
    }
    
    return _picInPicBtn;
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

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    // 处理解锁按钮的显示/隐藏
    [self hideMoreView];
}

- (void)hideMoreView{
    self.hidden = YES;
    [self removeFromSuperview];
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

#pragma mark 【Public】
- (void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState{
    self.hidden = NO;
    self.mediaPlayerState = mediaPlayerState;

    self.audioModeBtn.hidden = !mediaPlayerState.isSupportAudioMode;
    self.audioModeBtn.selected = mediaPlayerState.curPlayMode == PLVMediaPlayerPlayModeAudio ? YES:NO;
    
    self.picInPicBtn.hidden = !mediaPlayerState.isSupportWindowMode;
    self.picInPicBtn.selected = mediaPlayerState.curWindowMode == PLVMediaPlayerWindowModePIP ? YES:NO;
    
    [self updateUI];
}

#pragma mark 【Action]
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinMoreView_SwitchPlayMode:)]){
        [self.delegate mediaPlayerSkinMoreView_SwitchPlayMode:self];
    }
}

- (void)picInPicButtonClick:(UIButton *)picInPicButton{
    [self hideMoreView];
    picInPicButton.selected = !picInPicButton.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinMoreView_StartPictureInPicture:)]){
        [self.delegate mediaPlayerSkinMoreView_StartPictureInPicture:self];
    }
}
@end
