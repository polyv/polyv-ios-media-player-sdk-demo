//
//  PLVMediaPlayerSkinToastView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/3/1.
//

#import "PLVMediaPlayerSkinToastView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerConst.h"

@interface PLVMediaPlayerSkinToastView ()

@property (nonatomic, strong) UILabel *tipsLable;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) CGPoint targetPoint;

@end

@implementation PLVMediaPlayerSkinToastView

#pragma -- life cycle

- (instancetype)init{
    if (self = [super init]){
        [self initUI];
    }
    
    return self;
}

- (void)layoutSubviews{
    [self updapeUI];
}

- (void)initUI{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.tipsLable];
}

- (void)updapeUI{
    CGFloat bgView_H = 20;
    CGFloat start_x = self.targetPoint.x;
    CGFloat start_y = self.targetPoint.y - bgView_H - 5;

    NSAttributedString *tipsText = self.tipsLable.attributedText;
    if (tipsText.length){
        CGRect textRect = [tipsText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, bgView_H) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGFloat bgView_W = textRect.size.width + 20;

        self.bgView.frame = CGRectMake(start_x, start_y, bgView_W, bgView_H);
        self.tipsLable.frame = CGRectMake(10, 2, bgView_W - 20, bgView_H - 2*2);
    }
}

#pragma -- getter
- (UILabel *)tipsLable{
    if (!_tipsLable){
        _tipsLable = [[UILabel alloc] init];
        _tipsLable.backgroundColor = [UIColor clearColor];
    }
    return _tipsLable;
}

- (UIView *)bgView{
    if (!_bgView){
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 5;
        _bgView.backgroundColor = [UIColor blackColor];
    }
    
    return _bgView;
}

#pragma -- private method
- (void)hide{
    self.hidden = YES;
}

#pragma -- public method
- (void)showCurrentPlayTimeTips:(NSInteger)curTime targetPoint:(CGPoint)targetPoint uiStyle:(PLVMediaPlayerSkinToastViewUIStyle)uiStyle {
    if (curTime <= PLVMediaPlayerShowProgressTime) return;
    
    self.hidden = NO;
    self.targetPoint = targetPoint;
    
    NSString *timeStr = [PLVVodFdUtil secondsToString:curTime];
    NSString *tipsText = nil;
    if (uiStyle == PLVMediaPlayerSkinToastViewUIStyleLongVideo){
        tipsText = [NSString stringWithFormat:@"您上次观看至%@，已为您续播", timeStr];
    }
    else if (uiStyle == PLVMediaPlayerSkinToastViewUIStyleShortVideo){
        tipsText = [NSString stringWithFormat:@"已从%@续播", timeStr];
    }
    NSMutableAttributedString *tipsAttrString = [[NSMutableAttributedString alloc] initWithString:tipsText
                                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                                NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                                              }];
    NSRange range = [tipsText rangeOfString:timeStr];
    [tipsAttrString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:255/255 green:122/255 blue:10/255 alpha:1]} range:range];
    self.tipsLable.attributedText = tipsAttrString;
    
    [self updapeUI];
    
    // 2秒后自动隐藏
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hide) withObject:self afterDelay:3];
}

- (void)updateWithTargetPoint:(CGPoint)targetPoint{
    self.targetPoint = targetPoint;
    [self updapeUI];
}

@end
