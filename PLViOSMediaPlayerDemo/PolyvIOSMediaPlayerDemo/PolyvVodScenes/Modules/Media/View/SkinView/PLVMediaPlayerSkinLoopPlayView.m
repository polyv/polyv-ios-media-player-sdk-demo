//
//  PLVMediaPlayerSkinLoopPlayView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/8.
//

#import "PLVMediaPlayerSkinLoopPlayView.h"

@interface PLVMediaPlayerSkinLoopPlayView()

@property (nonatomic, strong) UIButton *btnLoopPlay;
@property (nonatomic, strong) UIButton *btnReturn;
@property (nonatomic, strong) UIView *backgroudView;

@end

@implementation PLVMediaPlayerSkinLoopPlayView

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
    [self addSubview:self.backgroudView];
    [self addSubview:self.btnReturn];
    [self addSubview:self.btnLoopPlay];
}

- (void)updateUI{
    CGFloat toppadding = 24;
    CGFloat leftPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
    
    //
    CGSize backButtonSize = CGSizeMake(40.0, 40.0);
    self.btnReturn.frame = CGRectMake(leftPadding, toppadding, backButtonSize.width, backButtonSize.height);
    self.btnReturn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
    //
    self.btnLoopPlay.frame = CGRectMake(0, 0, 60, 60);
    self.btnLoopPlay.center = self.center;
    
    self.backgroudView.frame = self.bounds;
}

- (UIButton *)btnReturn{
    if (!_btnReturn){
        _btnReturn = [[UIButton alloc] init];
        [_btnReturn setImage:[UIImage imageNamed:@"plv_skin_control_icon_back"] forState:UIControlStateNormal];
        [_btnReturn addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnReturn;
}

- (UIButton *)btnLoopPlay{
    if (!_btnLoopPlay){
        _btnLoopPlay = [[UIButton alloc] init];
        [_btnLoopPlay setImage:[UIImage imageNamed:@"plv_skin_control_icon_loopplay"] forState:UIControlStateNormal];
        [_btnLoopPlay setTitle:@"重播" forState:UIControlStateNormal];
        _btnLoopPlay.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btnLoopPlay addTarget:self action:@selector(loopButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self layoutButtonWithEdgeInsetsStyle:1 imageTitleSpace:2 button:_btnLoopPlay];
    }
    return _btnLoopPlay;
}

- (UIView *)backgroudView{
    if (!_backgroudView){
        _backgroudView = [[UIView alloc] init];
        _backgroudView.backgroundColor = [UIColor blackColor];
        _backgroudView.alpha = 0.5;
    }
    return _backgroudView;
}

#pragma mark -- button action
- (void)backButtonAction:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerLoopPlayView_BackEvent:)]){
        [self.delegate mediaPlayerLoopPlayView_BackEvent:self];
    }
}

- (void)loopButtonAction:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerLoopPlayView_LoopPlay:)]){
        [self.delegate mediaPlayerLoopPlayView_LoopPlay:self];
    }
    
    [self hiddenView];
}

- (void)hiddenView{
    [self removeFromSuperview];
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


#pragma mark -- public
- (void)showMediaPlayerLoopPlayView{
    self.hidden = NO;
}

@end
