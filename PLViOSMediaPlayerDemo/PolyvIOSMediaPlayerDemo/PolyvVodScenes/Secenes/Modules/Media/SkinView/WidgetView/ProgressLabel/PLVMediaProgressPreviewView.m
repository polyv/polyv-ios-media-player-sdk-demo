//
//  PLVLCMediaProgressView.m
//  PLVLiveScenesDemo
//
//  Created by Dhan on 2022/11/9.
//  Copyright © 2022 PLV. All rights reserved.
//

#import "PLVMediaProgressPreviewView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaProgressPreviewView()

#pragma mark UI
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *separatorLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *previewImageView;

@property (nonatomic, assign) NSTimeInterval durationTime;
@property (nonatomic, copy) NSString *progressImageString;
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, assign) BOOL isShowPreviewImageView;
@property (nonatomic, assign) NSTimeInterval intervalTime;

@property (nonatomic, assign) NSInteger currentCropIndex;



@end

@implementation PLVMediaProgressPreviewView

#pragma mark - [ Life Period ]

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressLabel];
    [self addSubview:self.separatorLabel];
    [self addSubview:self.durationLabel];
    
    self.intervalTime = 0;
    self.currentCropIndex = -1;
}

- (void)updateWithDurationTime:(NSTimeInterval)durationTime progressImageString:(NSString *)progressImageString ratio:(CGFloat)ratio {
    // 更新数据
    self.progressImageString = progressImageString;
    self.durationTime = durationTime;
    if (self.durationTime <=60) {
        self.intervalTime = 2;
    } else if (self.durationTime <= 240) {
        self.intervalTime = 3;
    } else if (self.durationTime <= 600) {
        self.intervalTime = 5;
    } else {
        self.intervalTime = 15;
    }
    
    // 更新View属性
    NSInteger hour = self.durationTime / 3600;
    if (hour > 0) { // 显示 时分秒
        self.progressLabel.text = @"00:00:00";
        self.durationLabel.text = [PLVVodMediaFdUtil secondsToString2:durationTime];
    } else { // 显示 分秒
        self.progressLabel.text = @"00:00";
        self.durationLabel.text = [PLVVodMediaFdUtil secondsToString:durationTime];
    }
    
    self.ratio = ratio;
    self.isShowPreviewImageView = [PLVVodMediaFdUtil checkStringUseable:self.progressImageString] && self.ratio>=1; // 有 雪碧图 且是 横向视频
    
    if (self.isShowPreviewImageView) { // 显示 预览图
        self.progressLabel.font = [UIFont fontWithName:@"PingFang SC" size:20];
        self.separatorLabel.font = [UIFont fontWithName:@"PingFang SC" size:20];
        self.durationLabel.font = [UIFont fontWithName:@"PingFang SC" size:20];
        
        [self addSubview:self.previewImageView];
    } else {  // 不显示 预览图
        self.progressLabel.font = [UIFont fontWithName:@"PingFang SC" size:28];
        self.separatorLabel.font = [UIFont fontWithName:@"PingFang SC" size:28];
        self.durationLabel.font = [UIFont fontWithName:@"PingFang SC" size:28];
    }
    
    // 更新View布局
    CGFloat boundsWeight = 300;
    CGFloat previewImageHeight = self.isShowPreviewImageView ? 90 : 0;
    CGFloat previewImageWeight = 160;
    CGFloat deliverHeight = 6;
    CGFloat labelHeight = self.isShowPreviewImageView ? 26 : 36;
    CGFloat separtorLabelWidth = 16;
    CGFloat bottomPadding = self.isShowPreviewImageView ? 0 : 12;

    self.bounds = CGRectMake(0, 
                             0,
                             boundsWeight,
                             previewImageHeight+deliverHeight+labelHeight+bottomPadding);
    
    if (self.isShowPreviewImageView) {
        self.previewImageView.frame = CGRectMake(CGRectGetWidth(self.bounds)/2-previewImageWeight/2,
                                                 0,
                                                 previewImageWeight,
                                                 previewImageHeight);
    }
    
    self.separatorLabel.frame = CGRectMake(CGRectGetWidth(self.bounds)/2-separtorLabelWidth/2,
                                           CGRectGetHeight(self.previewImageView.bounds)+deliverHeight,
                                           separtorLabelWidth,
                                           labelHeight);
    self.progressLabel.frame = CGRectMake(0,
                                          CGRectGetMinY(self.separatorLabel.frame),
                                          CGRectGetWidth(self.bounds)/2-separtorLabelWidth/2,
                                          labelHeight);
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.separatorLabel.frame),
                                          CGRectGetMinY(self.separatorLabel.frame),
                                          CGRectGetWidth(self.bounds)/2-separtorLabelWidth/2,
                                          labelHeight);
}

- (void)updateProgressTime:(NSTimeInterval)progressTime {
    NSInteger hour = self.durationTime / 3600;
    if (hour > 0) { // 显示 时分秒
        self.progressLabel.text = [PLVVodMediaFdUtil secondsToString2:progressTime];
    } else { // 显示 分秒
        self.progressLabel.text = [PLVVodMediaFdUtil secondsToString:progressTime];
    }
    
    if (!self.isShowPreviewImageView) {
        return;
    }
    NSInteger cropIndex = (NSInteger)floor(progressTime / self.intervalTime);
    if (self.currentCropIndex == cropIndex) { // 相同的预览图，不需要重新加载
        return;
    } else {
        self.currentCropIndex = cropIndex;
        __weak typeof(self) weakSelf = self;
        [self.previewImageView sd_setImageWithURL:[NSURL URLWithString:self.progressImageString]
                                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image && [image isKindOfClass:[UIImage class]]) {
                NSInteger countPerRow = 50;
                NSInteger row = cropIndex / countPerRow;
                NSInteger column = cropIndex % countPerRow;
                CGFloat width = image.size.width / countPerRow;
                CGFloat height = width / 16 * 9;
                CGFloat x = column * width;
                CGFloat y = row * height;
                CGRect cropRect = CGRectMake(x, y, width, height);

                if (CGRectContainsRect(CGRectMake(0, 0, image.size.width, image.size.height), cropRect)) {
                    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                    UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
                    weakSelf.previewImageView.image = cropImage;
                } else {
                    NSLog(@"crop-- error! cropRect not in image size ---------------------------");
                    NSLog(@"crop-- duration : %f", self.durationTime);
                    NSLog(@"crop-- intervalTime : %f", self.intervalTime);
                    NSLog(@"crop-- imageWidth : %f", image.size.width);
                    NSLog(@"crop-- imageHeight : %f", image.size.height);
                    NSLog(@"crop-- progress : %f", progressTime);
                    NSLog(@"crop-- currentCropIndex : %ld", self.currentCropIndex);
                    NSLog(@"crop-- row :◊ %ld", row);
                    NSLog(@"crop-- column : %ld", column);
                    NSLog(@"crop-- x : %f", x);
                    NSLog(@"crop-- y : %f", y);
                    NSLog(@"crop-- width : %f", width);
                    NSLog(@"crop-- height : %f", height);
                    NSLog(@"crop-- contain : %@", CGRectContainsRect(CGRectMake(0, 0, image.size.width, image.size.height), cropRect) ? @"YES" : @"NO");
                }
            }
        }];
    }
}

#pragma mark - [ Getter & Setter ]
- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textAlignment = NSTextAlignmentRight;
        _progressLabel.textColor = PLV_UIColorFromRGB(@"FFFFFF");
    }
    return _progressLabel;
}

- (UILabel *)separatorLabel {
    if (!_separatorLabel) {
        _separatorLabel = [[UILabel alloc] init];
        _separatorLabel.text = @"/";
        _separatorLabel.textAlignment = NSTextAlignmentCenter;
        _separatorLabel.textColor = PLV_UIColorFromRGBA(@"FFFFFF", 0.6);
    }
    return _separatorLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        _durationLabel.textColor = PLV_UIColorFromRGBA(@"FFFFFF", 0.6);
    }
    return _durationLabel;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
    }
    return _previewImageView;
}


@end
