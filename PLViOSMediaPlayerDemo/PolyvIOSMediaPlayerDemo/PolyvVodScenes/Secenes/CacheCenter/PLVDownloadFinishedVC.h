//
//  PLVDownloadFinishedVC.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVDownloadFinishedVC : UIViewController

@property (nonatomic, strong) void (^downloadCountDidChanged)(void);

@end

NS_ASSUME_NONNULL_END
