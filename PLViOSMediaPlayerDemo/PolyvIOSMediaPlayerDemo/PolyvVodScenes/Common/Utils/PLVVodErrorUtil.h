//
//  PLVVodErrorUtil.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/25.
//

#import <Foundation/Foundation.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodErrorUtil : NSObject

/// 根据错误码获取错误提示信息
+ (NSString *)getErrorMsgWithCode:(PLVVodErrorCode )errorCod;

@end

NS_ASSUME_NONNULL_END
