
//
//  PLVVodMediaVideoListView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by POLYV on 2025/7/1.
//

#import <UIKit/UIKit.h>

@class PLVVodMediaVideo;

@protocol PLVVodMediaVideoListViewDelegate <NSObject>

- (void)vodMediaVideoListView_didSelectVideo:(PLVVodMediaVideo *)video;

@end

@interface PLVVodMediaVideoListView : UIView

@property (nonatomic, weak) id<PLVVodMediaVideoListViewDelegate> delegate;

- (void)updateWithVideoList:(NSArray <PLVVodMediaVideo *>*)videoList;

@end
