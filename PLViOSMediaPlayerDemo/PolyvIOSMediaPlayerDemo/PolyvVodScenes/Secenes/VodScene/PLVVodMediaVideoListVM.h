
//
//  PLVVodMediaVideoListVM.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by POLYV on 2025/7/1.
//

#import <Foundation/Foundation.h>

@class PLVVodMediaVideo;

@interface PLVVodMediaVideoListVM : NSObject

- (void)requestVideoListWithCompletion:(void(^)(NSArray <PLVVodMediaVideo *> *videoList, NSError *error))completion;

@end
