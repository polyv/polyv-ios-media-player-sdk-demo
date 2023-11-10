//
//  PLVMediaPlayerSkinLockScreenView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import "PLVMediaPlayerSkinLockScreenView.h"

@implementation PLVMediaPlayerSkinLockScreenView

- (void)layoutSubviews{
    [super layoutSubviews];
    [self updateUI];
}

- (UIButton *)unlockScreenBtn{
    if (!_unlockScreenBtn){
        _unlockScreenBtn = [[UIButton alloc] init];
        [_unlockScreenBtn setImage:[UIImage imageNamed:@"plv_skin_control_icon_lock"] forState:UIControlStateNormal];
        [_unlockScreenBtn addTarget:self action:@selector(unlockScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _unlockScreenBtn;
}

- (void)setupUI{
    [self addSubview:self.unlockScreenBtn];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGes];
}

- (void)updateUI{
    self.unlockScreenBtn.frame = CGRectMake(90, self.bounds.size.height/2 - 40/2, 40, 40);
}

- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    return self;
}

- (void)fadeoutUnlockScreenBtn{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hiddenLockButton) withObject:self afterDelay:5];
}

- (void)hiddenLockButton{
    [UIView animateWithDuration:0.2 animations:^{
        self.unlockScreenBtn.hidden = YES;
    }];
}

#pragma makr --public
- (void)showLockScreenButton{
    self.unlockScreenBtn.hidden = NO;
    [self fadeoutUnlockScreenBtn];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    // 处理解锁按钮的显示/隐藏
    if (self.unlockScreenBtn.hidden){
        self.unlockScreenBtn.hidden = NO;
        // 自动隐藏
        [self fadeoutUnlockScreenBtn];
    }
    else{
        //
        [self hiddenLockButton];
    }
}

- (void)unlockScreenButtonClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinLockScreenView_unlockScreenEvent:)]){
        [self.delegate mediaPlayerSkinLockScreenView_unlockScreenEvent:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
