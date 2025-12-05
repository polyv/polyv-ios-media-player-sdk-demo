
//
//  PLVVodMediaVideoListCell.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by POLYV on 2025/7/1.
//

#import <UIKit/UIKit.h>

@class PLVVodMediaVideo;

@interface PLVVodMediaVideoListCell : UITableViewCell

- (void)updateWithModel:(PLVVodMediaVideo *)video;

@end
