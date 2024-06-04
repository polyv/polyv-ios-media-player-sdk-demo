//
//  PLVShortVideoFeedDataManager.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2023/9/7.
//

#import "PLVShortVideoFeedDataManager.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVVodMediaVideoNetwork.h"

#define PLVDelayLoadTime 0.5

@interface PLVShortVideoFeedDataManager ()

@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation PLVShortVideoFeedDataManager

#pragma mark - [ Public Method ]

- (void)refreshDataWithCompletion:(void (^)(void))completion failure:(void (^)(NSError * _Nonnull))failure {
    [PLVVodMediaVideoNetwork requestAccountVideoWithPageCount:10 page:1 completion:^(NSArray<NSDictionary *> * _Nonnull accountVideos) {
        NSArray *feedDataArray = [self feedDataArrayWithData:accountVideos];
        if (![PLVVodMediaFdUtil checkArrayUseable:feedDataArray]) {
            NSError *error = [NSError errorWithDomain:@"PLVVodMediaFeedDataManager" code:3 userInfo:nil];
            if (failure) {
                failure (error);
            }
            return;
        }
        [self refreshWithData:feedDataArray];
        self.currentPage = 1;
        if (completion) {
            completion();
        }
    }];
}

- (void)loadMoreDataWithCompletion:(void (^)(BOOL))completion failure:(void (^)(NSError * _Nonnull))failure {
    NSUInteger nextPage = self.currentPage + 1;
    [PLVVodMediaVideoNetwork requestAccountVideoWithPageCount:10 page:nextPage completion:^(NSArray<NSDictionary *> * _Nonnull accountVideos) {
        NSArray *feedDataArray = [self feedDataArrayWithData:accountVideos];
        if (![PLVVodMediaFdUtil checkArrayUseable:feedDataArray]) {
            NSError *error = [NSError errorWithDomain:@"PLVVodMediaFeedDataManager" code:3 userInfo:nil];
            if (failure) {
                failure (error);
            }
            return;
        }
        
        self.currentPage = nextPage;
        [self appendWithData:feedDataArray];
        
        BOOL lastPage = accountVideos.count < 10;
        
        if (completion) {
            completion(lastPage);
        }
    }];
}

- (NSArray <PLVVodMediaFeedData *> *)feedDataArray {
    return self.currentData;
}

- (NSArray *)feedDataArrayWithData:(NSArray *)data {
    
    if (![PLVVodMediaFdUtil checkArrayUseable:data]) {
        return nil;
    }
    
    NSMutableArray *feedDataMuArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dict = data[i];
        NSString *vid = [dict objectForKey:@"vid"];
        if ([PLVVodMediaFdUtil checkStringUseable:vid]) {
            PLVVodMediaFeedData *feedData = [[PLVVodMediaFeedData alloc] init];
            feedData.vid = vid;
            [feedDataMuArray addObject:feedData];
        }
    }
    return [feedDataMuArray copy];
}

- (PLVVodMediaFeedData *)feedDataInFeedDataArrayAtIndex:(NSUInteger)index {
    if (![PLVVodMediaFdUtil checkArrayUseable:self.currentData] || index > self.currentData.count || ![self.currentData[index] isKindOfClass:PLVVodMediaFeedData.class]) {
        return nil;
    }
    return self.currentData[index];
}

@end
