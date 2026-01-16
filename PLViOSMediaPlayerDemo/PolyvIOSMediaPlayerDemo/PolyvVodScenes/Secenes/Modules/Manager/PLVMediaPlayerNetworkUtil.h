//
//  PLVVodMediaNetworkUtil.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodMediaNetworkUtil : NSObject

+ (void)requestData:(NSURLRequest *)request
            success:(void (^)(NSDictionary *dic))successHandler
            failure:(void (^)(NSError *error))failureHandler;

+ (void)requestData:(NSURLRequest *)request
         completion:(void (^)(NSData *data, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
