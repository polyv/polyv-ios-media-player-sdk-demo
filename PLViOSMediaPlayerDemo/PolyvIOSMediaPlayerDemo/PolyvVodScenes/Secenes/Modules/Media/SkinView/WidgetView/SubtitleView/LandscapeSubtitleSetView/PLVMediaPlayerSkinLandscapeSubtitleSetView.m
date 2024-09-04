//
//  PLVMediaPlayerSkinLandscapeSubtitleSetView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/15.
//

#import "PLVMediaPlayerSkinLandscapeSubtitleSetView.h"
#import "UIImage+PLVVodMediaTint.h"
#import "PLVMediaPlayerSkinLandscapeSubtitleSetCell.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

static NSString *LandscapeSubtitleCellID = @"LandscapeSubtitleCellID";

@interface PLVMediaPlayerSkinLandscapeSubtitleSetView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleSwitch;
@property (nonatomic, strong) UISwitch *buttonSwitch;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) CAGradientLayer *bgLayer;

@property (nonatomic, strong) PLVMediaPlayerSubtitleConfigModel *configModel;

@end

@implementation PLVMediaPlayerSkinLandscapeSubtitleSetView

#pragma mark [life cycle]
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    
    return self;
}

#pragma mark [init]
- (void)setupUI{
    //
    [self addSubview:self.backgroudView];
    [self.layer addSublayer:self.bgLayer];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.backgroudView addGestureRecognizer:tapGes];

    // close
    [self addSubview:self.closeBtn];
    
    // switch
    [self addSubview:self.titleSwitch];
    [self addSubview:self.buttonSwitch];
    
    // subtitle table
    [self addSubview:self.tableView];
}

- (void)updateUI{
    
    CGSize buttonSize = CGSizeMake(24, 24);
    CGFloat start_x = self.bounds.size.width - buttonSize.width -20;
    CGFloat start_y = 20;
    
    self.backgroudView.frame = self.bounds;
    self.bgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.closeBtn.frame = CGRectMake(start_x, start_y, buttonSize.width, buttonSize.height);
    
    // switch button
    start_y = 74;
    start_x = self.bounds.size.width - (51 + 100);
    self.buttonSwitch.frame = CGRectMake(start_x, start_y, 51, 31);
    
    // title switch
    start_x = CGRectGetMinX(self.buttonSwitch.frame) - 20 - 60;
    self.titleSwitch.frame = CGRectMake(start_x, start_y, 60, 20);
    
    // table
    start_x = CGRectGetMinX(self.titleSwitch.frame);
    start_y = CGRectGetMaxY(self.titleSwitch.frame) + 26;
    self.tableView.frame = CGRectMake(start_x, start_y, self.bounds.size.width - start_x, self.bounds.size.height - start_y);
}

- (CAGradientLayer *)bgLayer{
    if (!_bgLayer) {
        _bgLayer = [CAGradientLayer layer];
        _bgLayer.startPoint = CGPointMake(0.0, 0);
        _bgLayer.endPoint = CGPointMake(1, 0);
        _bgLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8].CGColor];
        _bgLayer.locations = @[@(0.0), @(1.0f)];
    }
    return _bgLayer;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = [[UIButton alloc] init];
        UIImage *origImg = [UIImage imageNamed:@"plv_skin_menu_icon_close"];
        [_closeBtn setImage:[origImg imageWithCustomTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeBtn;
}

- (UILabel *)titleSwitch{
    if (!_titleSwitch){
        _titleSwitch = [[UILabel alloc] init];
        _titleSwitch.text = @"显示字幕";
        _titleSwitch.font = [UIFont systemFontOfSize:14];
        _titleSwitch.textColor = [UIColor whiteColor];
        _titleSwitch.backgroundColor = [UIColor clearColor];
    }
    
    return _titleSwitch;
}

- (UISwitch *)buttonSwitch{
    if (!_buttonSwitch){
        _buttonSwitch = [[UISwitch alloc] init];
        [_buttonSwitch setOnTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#3F76FC" alpha:1.0]];

        [_buttonSwitch addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _buttonSwitch;
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PLVMediaPlayerSkinLandscapeSubtitleSetCell class] forCellReuseIdentifier:LandscapeSubtitleCellID];
    }
    
    return _tableView;
}

- (UIView *)backgroudView{
    if (!_backgroudView){
        _backgroudView = [[UIView alloc] init];
    }
    return _backgroudView;
}

#pragma mark [button action]
- (void)closeButtonClick:(UIButton *)button{
    [self hideSetView];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tagGesture{
    [self hideSetView];

}

- (void)switchBtnClick:(UISwitch *)switchBtn{
    if(switchBtn.on == YES) {
        NSLog(@"开关切换为开");
        self.tableView.hidden = NO;
        self.configModel.subtitlesEnabled = YES;
    } else if(switchBtn.on == NO) {
        NSLog(@"开关切换为关");
        self.tableView.hidden = YES;
        self.configModel.subtitlesEnabled = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinLandscapeSubtitleSetView_SelectSubtitle)]){
        [self.delegate mediaPlayerSkinLandscapeSubtitleSetView_SelectSubtitle];
    }
}

#pragma mark [private]
- (void)hideSetView{
    self.hidden = YES;
}

- (void)setConfigModel:(PLVMediaPlayerSubtitleConfigModel *)configModel{
    _configModel = configModel;
    
    if (!self.configModel.subtitlesEnabled){
        self.buttonSwitch.on = NO;
        self.tableView.hidden = YES;
    }
    else{
        self.buttonSwitch.on = YES;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

#pragma mark [UITableViewDataSource]
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.configModel.subtitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PLVMediaPlayerSkinLandscapeSubtitleSetCell *cell = [tableView dequeueReusableCellWithIdentifier:LandscapeSubtitleCellID 
                                                                                       forIndexPath:indexPath];
    if (!cell){
        cell = [[PLVMediaPlayerSkinLandscapeSubtitleSetCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                 reuseIdentifier:LandscapeSubtitleCellID];
    }
    PLVMediaPlayerSkinSubtitleItemModel *item = self.configModel.subtitles[indexPath.row];
    BOOL selected = NO;
    if (self.configModel.selIndex == indexPath.row){
        selected = YES;
    }
    [cell configSubtitleText:item.showName select:selected];
    
    return cell;
}

#pragma mark [UITableViewDelegate]
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 实时刷新字幕
    self.configModel.selIndex = indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinLandscapeSubtitleSetView_SelectSubtitle)]){
        [self.delegate mediaPlayerSkinLandscapeSubtitleSetView_SelectSubtitle];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark [public]
- (void)showWithConfigModel:(PLVMediaPlayerSubtitleConfigModel *)configModel{
    self.configModel = configModel;
    self.hidden = NO;
    //
    [self updateUI];
}

@end
