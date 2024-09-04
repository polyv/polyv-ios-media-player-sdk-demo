//
//  PLVMediaPlayerSubtitleConfigModel.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/14.
//

#import <Foundation/Foundation.h>
#import <PolyvMediaPlayerSDK/PLVVodMediaVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaPlayerSkinSubtitleItemModel : NSObject

@property (nonatomic, copy, nullable) NSString *subtileKeyName; // 字幕唯一名称，用于获取字幕内容
@property (nonatomic, copy, nullable) NSString *showName; // UI 层展示字幕名称
@property (nonatomic, assign) BOOL isDoubleSubtitle; // 是否是双语字幕

@end

@interface PLVMediaPlayerSubtitleConfigModel : NSObject

@property (nonatomic, assign) BOOL subtitlesEnabled; // 字幕是否显示。NO-不显示字幕；YES-默认显示第一份字幕文件，若双字幕开启且双字幕为默认字幕，则默认显示双字幕
@property (nonatomic, assign) BOOL subtitlesDoubleDefault; // 设置双字幕为默认字幕
@property (nonatomic, assign) BOOL subtitlesDoubleEnabled; // 双字幕功能是否开启。NO-未开启；YES-开启
@property (nonatomic, assign) NSInteger selIndex; // 当前选中字幕索引
@property (nonatomic, copy, readonly) NSString *selectedSubtitleKey; // 选中的字幕
@property (nonatomic, assign, readonly) BOOL isCurDouble; // 当前双语字幕
@property (nonatomic, strong) NSArray <PLVMediaPlayerSkinSubtitleItemModel *> *subtitles; // 字幕数组

/// 初始化
- (instancetype)initWithVideoModel:(PLVVodMediaVideo *)videoModel;

@end

NS_ASSUME_NONNULL_END
