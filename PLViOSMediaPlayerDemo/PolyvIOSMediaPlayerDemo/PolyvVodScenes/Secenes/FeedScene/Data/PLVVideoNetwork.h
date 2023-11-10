//
//  PLVVideoNetwork.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVideoNetwork : NSObject

+ (void)requestAccountVideoWithPageCount:(NSInteger)pageCount
                                    page:(NSInteger)page
                              completion:(void (^)(NSArray<NSDictionary *> *accountVideos))completion;

@end

NS_ASSUME_NONNULL_END
