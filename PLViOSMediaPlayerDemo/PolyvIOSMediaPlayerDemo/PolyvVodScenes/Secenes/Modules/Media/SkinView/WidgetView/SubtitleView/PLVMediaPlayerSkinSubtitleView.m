//
//  PLVMediaPlayerSkinSubtitleView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/13.
//

#import "PLVMediaPlayerSkinSubtitleView.h"

@interface PLVMediaPlayerSkinSubtitleView ()

@property (nonatomic, assign) CGPoint targetPoint;
@property (nonatomic, assign) BOOL doubleSubtile;

@end

@implementation PLVMediaPlayerSkinSubtitleView

#pragma mark [life cycle]

- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark [init]
- (void)setupUI{
    self.targetPoint = CGPointMake(0, self.frame.size.height -10);
    self.doubleSubtile = NO;
    
    // 首字幕
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.subtitleTopLabel];
    
    // 双字幕 - 第二组字幕
    [self addSubview:self.subtitleLabel2];
    [self addSubview:self.subtitleTopLabel2];
}

- (UILabel *)subtitleLabel{
    if (!_subtitleLabel){
        _subtitleLabel = [[UILabel alloc] init];
    }
    
    return _subtitleLabel;
}

- (UILabel *)subtitleLabel2{
    if (!_subtitleLabel2){
        _subtitleLabel2 = [[UILabel alloc] init];
    }
    
    return _subtitleLabel2;
}

- (UILabel *)subtitleTopLabel{
    if (!_subtitleTopLabel){
        _subtitleTopLabel = [[UILabel alloc] init];
    }
    return _subtitleTopLabel;
}

- (UILabel *)subtitleTopLabel2{
    if (!_subtitleTopLabel2){
        _subtitleTopLabel2 = [[UILabel alloc] init];
    }
    return _subtitleTopLabel2;
}

#pragma mark [public]
- (void)updateUIWithSubviewTargetPoint:(CGPoint)targetPoint{
    self.targetPoint = targetPoint;
}

- (void)freshUIWithDoubleSubtile:(BOOL)doubleSubtitle{
    self.doubleSubtile = doubleSubtitle;
    if (doubleSubtitle){
        // 双语 上字幕
        self.subtitleLabel.hidden = NO;
        // 双语 下字幕
        self.subtitleLabel2.hidden = NO;
        
        NSAttributedString *subtile1 = self.subtitleLabel.attributedText;
        CGRect subtile_rect1 = [subtile1 boundingRectWithSize:CGSizeMake(self.bounds.size.width, 1000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        NSAttributedString *subtitle2 = self.subtitleLabel2.attributedText;
        CGRect subtitle_rect2 = [subtitle2 boundingRectWithSize:CGSizeMake(self.bounds.size.width, 1000)
                                                        options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        // 布局
        CGFloat start_y = self.targetPoint.y - subtitle_rect2.size.height -15;

        // 下字幕
        CGFloat start_x = (self.bounds.size.width - subtitle_rect2.size.width)/2;
        self.subtitleLabel2.frame = CGRectMake(start_x, start_y, subtitle_rect2.size.width,  subtitle_rect2.size.height);

        // 上字幕
        start_x = (self.bounds.size.width - subtile_rect1.size.width)/2;
        start_y = CGRectGetMinY(self.subtitleLabel2.frame) - subtile_rect1.size.height;
        self.subtitleLabel.frame = CGRectMake(start_x, start_y, subtile_rect1.size.width, subtile_rect1.size.height);
    }
    else{
        // 单字幕
        self.subtitleLabel.hidden = NO;
        self.subtitleLabel2.hidden = YES;
        
        NSAttributedString *subtile1 = self.subtitleLabel.attributedText;
        CGRect subtile_rect1 = [subtile1 boundingRectWithSize:CGSizeMake(self.bounds.size.width, 1000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        // 布局
        CGFloat start_y = self.targetPoint.y - subtile_rect1.size.height -15;

        // 下字幕
        CGFloat start_x = (self.bounds.size.width - subtile_rect1.size.width)/2;
        self.subtitleLabel.frame = CGRectMake(start_x, start_y, subtile_rect1.size.width,  subtile_rect1.size.height);
    }
}

@end
