//
//  PLVDownloadNoDataTipsView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/9.
//

#import "PLVDownloadNoDataTipsView.h"

@interface PLVDownloadNoDataTipsView ()

@property (nonatomic, strong) UILabel *labelTips;
@property (nonatomic, strong) UIImageView *imageViewTips;

@end

@implementation PLVDownloadNoDataTipsView


#pragma mark -- life cycle
- (instancetype)init{
    if (self = [super init]){
        [self setupViews];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)setupViews{
    [self addSubview:self.imageViewTips];
    [self addSubview:self.labelTips];
}

- (void)updateUI{
    CGFloat start_x = (self.bounds.size.width - 60)/2;
    CGFloat start_y = 140;
    self.imageViewTips.frame = CGRectMake(start_x, start_y, 60, 60);
    
    start_x = (self.bounds.size.width - 100)/2;
    start_y = CGRectGetMaxY(self.imageViewTips.frame) + 10;
    self.labelTips.frame = CGRectMake(start_x, start_y, 100, 18);
}

#pragma mark -- init
- (UILabel *)labelTips{
    if (!_labelTips){
        _labelTips = [[UILabel alloc] init];
        _labelTips.font = [UIFont systemFontOfSize:12];
        _labelTips.textColor = [UIColor whiteColor];
        _labelTips.text = @"暂无下载内容";
        _labelTips.textAlignment = NSTextAlignmentCenter;
    }
    
    return _labelTips;
}

- (UIImageView *)imageViewTips{
    if (!_imageViewTips){
        _imageViewTips = [[UIImageView alloc] init];
        _imageViewTips.image = [UIImage imageNamed:@"plv_download_nodata"];
    }
    
    return _imageViewTips;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
