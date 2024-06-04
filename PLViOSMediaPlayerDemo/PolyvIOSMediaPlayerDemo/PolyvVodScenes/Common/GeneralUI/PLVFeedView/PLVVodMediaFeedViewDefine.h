//
//  PLVVodMediaFeedViewDefine.h
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/27.
//  Copyright © 2023 PLV. All rights reserved.
//

#ifndef PLVVodMediaFeedViewDefine_h
#define PLVVodMediaFeedViewDefine_h

@protocol PLVVodMediaFeedItemCustomViewDelegate <NSObject>

// 视图复用ID
@property (nonatomic, strong) NSString *reuseIdentifier;

// 视图必须实现的协议方法
- (void)setActive:(BOOL)active;


@end

#endif /* PLVVodMediaFeedViewDefine_h */
