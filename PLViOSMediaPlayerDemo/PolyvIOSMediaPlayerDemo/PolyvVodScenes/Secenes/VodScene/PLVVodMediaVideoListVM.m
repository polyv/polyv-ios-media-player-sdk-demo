
//
//  PLVVodMediaVideoListVM.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by POLYV on 2025/7/1.
//

#import "PLVVodMediaVideoListVM.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVVodMediaVideoNetwork.h"

@implementation PLVVodMediaVideoListVM

- (void)requestVideoListWithCompletion:(void (^)(NSArray<PLVVodMediaVideo *> *, NSError *))completion {
    [PLVVodMediaVideoNetwork requestAccountVideoWithPageCount:20 page:1 completion:^(NSArray<NSDictionary *> *accountVideos) {
        if (accountVideos) {
            NSMutableArray *videoList = [NSMutableArray array];
            dispatch_group_t group = dispatch_group_create();
            for (NSDictionary *videoInfo in accountVideos) {
                dispatch_group_enter(group);
                [PLVVodMediaVideo requestVideoPriorityCacheWithVid:[videoInfo valueForKey:@"vid"] completion:^(PLVVodMediaVideo *video, NSError *error) {
                    if (video) {
                        [videoList addObject:video];
                    }
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (completion) {
                    completion([videoList copy], nil);
                }
            });
        } else {
            if (completion) {
                completion(nil, [NSError errorWithDomain:@"PLVVodMediaVideoListVM" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Request video list failed"}]);
            }
        }
    }];
}

@end
