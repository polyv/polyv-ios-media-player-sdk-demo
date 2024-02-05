//
//  PLVMediaPlayerSkinLoadingView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/1/12.
//

#import "PLVMediaPlayerSkinLoadingView.h"

@interface PLVMediaPlayerSkinLoadingView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation PLVMediaPlayerSkinLoadingView

- (instancetype)init{
    if (self = [super init]){
        [self initUI];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)initUI{
//    [self addSubview:self.loadingView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.loadSpeadLable];
    [self.contentView addSubview:self.loadTipsLable];
}

- (void)updateUI{
//    self.loadingView.frame = CGRectMake(0, 0, 50, 50);
//    self.loadingView.center = self.center;
    self.contentView.bounds = CGRectMake(0, 0, 120, 60);
    self.contentView.center = self.center;
    CGFloat start_x = 0;
    CGFloat start_y = 0;
    self.loadSpeadLable.frame = CGRectMake(start_x, start_y, 120, 20);
    
    start_y = CGRectGetMaxY(self.loadSpeadLable.frame) + 10;
    self.loadTipsLable.frame = CGRectMake(start_x, start_y, 120, 20);
}

- (UIActivityIndicatorView *)loadingView{
    if (!_loadingView){
        if (@available(iOS 13.0, *)) {
            _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            // Fallback on earlier versions
            _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    }
    
    return _loadingView;
}

- (UILabel *)loadSpeadLable{
    if (!_loadSpeadLable){
        _loadSpeadLable = [[UILabel alloc] init];
        _loadSpeadLable.font = [UIFont systemFontOfSize:14];
        _loadSpeadLable.textColor = [UIColor whiteColor];
        _loadSpeadLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _loadSpeadLable;
}

- (UILabel *)loadTipsLable{
    if (!_loadTipsLable){
        _loadTipsLable = [[UILabel alloc] init];
        _loadTipsLable.font = [UIFont systemFontOfSize:14];
        _loadTipsLable.text = @"正在加载中 请稍等";
        _loadTipsLable.textColor = [UIColor whiteColor];
        _loadTipsLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _loadTipsLable;
}

- (UIView *)contentView{
    if (!_contentView){
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

@end
