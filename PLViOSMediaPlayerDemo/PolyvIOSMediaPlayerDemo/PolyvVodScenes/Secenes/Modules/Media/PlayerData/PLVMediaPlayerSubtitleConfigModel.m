//
//  PLVMediaPlayerSubtitleConfigModel.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/14.
//

#import "PLVMediaPlayerSubtitleConfigModel.h"

@implementation PLVMediaPlayerSkinSubtitleItemModel

- (instancetype)init{
    if (self = [super init]){
        self.subtileKeyName = nil;
        self.showName = nil;
    }
    
    return self;
}

@end

@implementation PLVMediaPlayerSubtitleConfigModel

- (instancetype)initWithVideoModel:(PLVVodMediaVideo *)videoModel{
    if (self = [super init]){
        self.subtitlesEnabled = videoModel.player.subtitlesEnabled;
        self.subtitlesDoubleEnabled = videoModel.player.subtitlesDoubleEnabled;
        self.subtitlesDoubleDefault = videoModel.player.subtitlesDoubleDefault;
        
        NSMutableArray *mulArray = [[NSMutableArray alloc] init];
        // 添加双语字幕
        if (videoModel.match_srt.count == 2){
            PLVVodMediaVideoDoubleSubtitleItem *firstItem = videoModel.match_srt[0];
            PLVVodMediaVideoDoubleSubtitleItem *secondItem = videoModel.match_srt[1];
            
            PLVMediaPlayerSkinSubtitleItemModel *subItem = [[PLVMediaPlayerSkinSubtitleItemModel alloc] init];
            subItem.isDoubleSubtitle = YES;
            subItem.showName = [NSString stringWithFormat:@"显示双语: %@/%@", firstItem.title, secondItem.title];
            subItem.subtileKeyName = @"双语";
            [mulArray addObject:subItem];
        }
        
        // 添加单语字幕
        for (PLVVodMediaVideoSubtitleItem *item in videoModel.srts){
            PLVMediaPlayerSkinSubtitleItemModel *subItem = [[PLVMediaPlayerSkinSubtitleItemModel alloc] init];
            subItem.isDoubleSubtitle = NO;
            subItem.showName = item.title;
            subItem.subtileKeyName = item.title;
            
            [mulArray addObject:subItem];
        }
        self.subtitles = [NSArray arrayWithArray:mulArray];
        
        // 计算默认索引
        if (self.subtitlesEnabled){
            if (self.subtitlesDoubleEnabled && self.subtitlesDoubleDefault){
                self.selIndex = 0; // 默认展示双语字幕
            }
            else if (self.subtitlesDoubleEnabled && videoModel.match_srt.count == 2){
                self.selIndex = 1; // 默认展示单字幕 索引从1 开始
            }else{
                self.selIndex = 0; // 默认展示单字幕 索引从0 开始, 没有双字幕选项
            }
        }
        else{
            self.selIndex = -1;
        }
    }
    
    return self;
}

- (NSString *)selectedSubtitleKey{
    if ((self.selIndex == -1) || self.subtitles.count == 0){
        return nil;
    }
    else{
        PLVMediaPlayerSkinSubtitleItemModel *item = [self.subtitles objectAtIndex:self.selIndex];
        return item.subtileKeyName;
    }
    return nil;
}

- (BOOL)isCurDouble{
    if ([[self selectedSubtitleKey] isEqualToString:@"双语"]){
        return YES;
    }
    
    return NO;
}

@end
