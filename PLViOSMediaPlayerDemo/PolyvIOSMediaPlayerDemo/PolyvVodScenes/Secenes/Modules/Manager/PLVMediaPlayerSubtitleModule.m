//
//  PLVMediaPlayerSubtitleModule.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/13.
//

#import "PLVMediaPlayerSubtitleModule.h"
#import "PLVVodMediaSubtitleManager.h"
#import "PLVVodMediaCommonUtil.h"

@interface PLVMediaPlayerSubtitleModule ()

@property (nonatomic, strong) PLVVodMediaSubtitleManager *subtitleManager;
@property (nonatomic, strong) PLVVodMediaVideo *video;
@property (nonatomic, strong) NSString *selectedSubtitleKey;

@property (nonatomic, assign) UILabel *subtitleLabel;
@property (nonatomic, assign) UILabel *subtitleTopLabel;
@property (nonatomic, assign) UILabel *subtitleLabel2;
@property (nonatomic, assign) UILabel *subtitleTopLabel2;

@end

@implementation PLVMediaPlayerSubtitleModule

#pragma mark [init]

- (instancetype)init{
    if (self = [super init]){
        [self initModule];
    }
    return self;
}

- (void)initModule{
//    self.subtitleMgr = [PLVVodSubtitleManager alloc] 
    
}

#pragma mark [public]

- (void)loadSubtitlsWithVideoModel:(PLVVodMediaVideo *)videoModel 
                             label:(nonnull UILabel *)label
                          topLabel:(nonnull UILabel *)topLabel
                            label2:(nonnull UILabel *)label2
                         topLabel2:(nonnull UILabel *)topLabel2{
    
    self.video = videoModel;
    self.subtitleLabel = label;
    self.subtitleTopLabel  = topLabel;
    self.subtitleLabel2 = label2;
    self.subtitleTopLabel2 = topLabel;
    
    // 计算默认显示字幕
    self.selectedSubtitleKey =@"";
    if (self.video.player.subtitlesEnabled){
        if (self.video.player.subtitlesDoubleEnabled && self.video.player.subtitlesDoubleDefault){
            self.selectedSubtitleKey = @"双语"; // 默认展示双语字幕
        }
        else{
            if (self.video.srts.count){
                self.selectedSubtitleKey = self.video.srts[0].title; // 默认展示单字幕
            }
        }
    }
   
    if (![PLVVodMediaCommonUtil isNilString:self.selectedSubtitleKey]){
        [self loadSubtitle];
    }
}

- (void)updateSubtitleWithName:(NSString *)subtitleName show:(BOOL)show{
    if ([PLVVodMediaCommonUtil isNilString:subtitleName] || !show){
        // 关闭字幕
        [self hideSubtitle:YES];
        return;
    }
    
    // 选中同一个字幕类型
    if (subtitleName && [subtitleName isEqual:self.selectedSubtitleKey]){
        [self hideSubtitle:NO];
        return;
    }
    
    // 字幕切换
    self.selectedSubtitleKey = subtitleName;
    [self hideSubtitle:NO];
    [self loadSubtitle];
}

- (void)showSubtilesWithPlaytime:(NSTimeInterval )playtime{
    [self.subtitleManager showSubtitleWithTime:playtime];
}

#pragma mark [Private]
- (void)hideSubtitle:(BOOL)hidden{
    self.subtitleLabel.hidden = hidden;
    self.subtitleTopLabel.hidden  = hidden;
    self.subtitleLabel2.hidden = hidden;
    self.subtitleTopLabel2.hidden = hidden;
}

- (void)loadSubtitle{
    PLVVodMediaSubtitleItemStyle *topStyle;
    PLVVodMediaSubtitleItemStyle *bottomStyle;
    PLVVodMediaSubtitleItemStyle *singleStyle;
    // 获取字幕样式
    for (PLVVodMediaVideoSubtitlesStyle *style in self.video.player.subtitles) {
        if ([style.style isEqualToString:@"double"] && [style.position isEqualToString:@"top"]) {
            topStyle = [PLVVodMediaSubtitleItemStyle styleWithTextColor:[self colorFromHexString:style.fontColor] bold:style.fontBold italic:style.fontItalics backgroundColor:[self colorFromRGBAString:style.backgroundColor]];
        } else if ([style.style isEqualToString:@"double"] && [style.position isEqualToString:@"bottom"]) {
            bottomStyle = [PLVVodMediaSubtitleItemStyle styleWithTextColor:[self colorFromHexString:style.fontColor] bold:style.fontBold italic:style.fontItalics backgroundColor:[self colorFromRGBAString:style.backgroundColor]];
        } else if ([style.style isEqualToString:@"single"]) {
            singleStyle = [PLVVodMediaSubtitleItemStyle styleWithTextColor:[self colorFromHexString:style.fontColor] bold:style.fontBold italic:style.fontItalics backgroundColor:[self colorFromRGBAString:style.backgroundColor]];
        }
    }
    PLVVodMediaVideoDoubleSubtitleItem *firstItem;
    PLVVodMediaVideoDoubleSubtitleItem *secondItem;
    BOOL doubleSubtitleNeedShow = [self.selectedSubtitleKey isEqualToString:@"双语"] && self.video.match_srt.count == 2;
    BOOL firstItemAtTop = NO;
    if (doubleSubtitleNeedShow) {
        firstItem = self.video.match_srt[0];
        secondItem = self.video.match_srt[1];
        firstItemAtTop = [firstItem.position isEqualToString:@"topSubtitles"];
    }
    
    // 获取在线字幕内容并设置字幕
    __weak typeof(self) weakSelf = self;
    if (doubleSubtitleNeedShow) { // 在线双字幕
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSString *srtContent;
        __block NSString *srtContent2;
        [self.class requestStringWithUrl:firstItem.url completion:^(NSString *string) {
            NSLog(@"[字幕] -- 在线双字幕第一部分");
            srtContent = string;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [self.class requestStringWithUrl:secondItem.url completion:^(NSString *string) {
            NSLog(@"[字幕] -- 在线双字幕第二部分");
            srtContent2 = string;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        BOOL firstItemAtTop = [firstItem.position isEqualToString:@"topSubtitles"];
        self.subtitleManager = [PLVVodMediaSubtitleManager managerWithSubtitle:firstItemAtTop ? srtContent : srtContent2
                                                                 style:topStyle
                                                                 error:nil
                                                             subtitle2:firstItemAtTop ? srtContent2 : srtContent
                                                                style2:bottomStyle
                                                                   error2:nil
                                                                 label:self.subtitleLabel2  // 底部字幕
                                                              topLabel:self.subtitleTopLabel
                                                                label2:self.subtitleLabel   // 上字幕
                                                             topLabel2:self.subtitleTopLabel2];
        
    } else { // 在线单字幕
        NSString *srtUrl = nil;
        if (!self.selectedSubtitleKey || ![self.selectedSubtitleKey isKindOfClass:NSString.class] || !self.selectedSubtitleKey.length) {
            NSLog(@"[字幕] -- 在线单字幕，字幕名称为空！");
            return;
        }
        
        for (PLVVodMediaVideoSubtitleItem *item in self.video.srts) {
            if ([item.title isEqualToString:self.selectedSubtitleKey]) {
                srtUrl = item.url;
                break;
            }
        }

        [self.class requestStringWithUrl:srtUrl completion:^(NSString *string) {
            NSLog(@"[字幕] -- 在线单字幕");
            NSString *srtContent = string;
            weakSelf.subtitleManager = [PLVVodMediaSubtitleManager managerWithSubtitle:srtContent
                                                                            style:singleStyle
                                                                            error:nil
                                                                        subtitle2:nil
                                                                           style2:nil
                                                                           error2:nil
                                                                            label:self.subtitleLabel
                                                                         topLabel:self.subtitleTopLabel
                                                                           label2:self.subtitleLabel2
                                                                        topLabel2:self.subtitleTopLabel2];
        }];
    }
    
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    return [self colorFromHexString:hexString alpha:1.0];
}

- (UIColor *)colorFromHexString:(NSString *)hexString alpha:(float)alpha {
    if (!hexString || hexString.length < 6) {
        return [UIColor whiteColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString rangeOfString:@"#"].location == 0) {
        [scanner setScanLocation:1]; // bypass '#' character
    }
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

- (UIColor *)colorFromRGBAString:(NSString *)rgbaString {
    // 去除字符串两端的空白字符
    rgbaString = [rgbaString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 判断字符串是否符合 rgba() 格式
    if ([rgbaString hasPrefix:@"rgba("] && [rgbaString hasSuffix:@")"]) {
        // 去除 "rgba(" 和 ")"
        NSString *valuesString = [rgbaString substringWithRange:NSMakeRange(5, rgbaString.length - 6)];
        
        // 拆分颜色值
        NSArray *components = [valuesString componentsSeparatedByString:@","];
        if (components.count == 4) {
            CGFloat red = [[components objectAtIndex:0] floatValue] / 255.0;
            CGFloat green = [[components objectAtIndex:1] floatValue] / 255.0;
            CGFloat blue = [[components objectAtIndex:2] floatValue] / 255.0;
            CGFloat alpha = [[components objectAtIndex:3] floatValue];
            
            return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }
    }
    
    // 如果字符串格式不正确,返回 nil
    return nil;
}

+ (void)requestStringWithUrl:(NSString *)url completion:(void (^)(NSString *string))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string.length && completion) {
            completion(string);
        }
        else{
            completion(nil);
        }
    }] resume];
}


@end
