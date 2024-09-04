//
//  PLVMediaPlayerSkinSubtitleSetView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/14.
//

#import "PLVMediaPlayerSkinSubtitleSetView.h"
#import "PLVMediaPlayerSkinSubtitleSetCell.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

static NSString *REUSEID = @"CELLID";

@interface PLVMediaPlayerSkinSubtitleSetView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIButton *returnBtn;
@property (nonatomic, strong) UILabel *switchTitle;
@property (nonatomic, strong) UISwitch *switchBtn;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) PLVMediaPlayerSubtitleConfigModel *configModel;

@end

@implementation PLVMediaPlayerSkinSubtitleSetView

#pragma mark [life cycle]
- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

#pragma mark [init]

- (void)setupUI{
    [self addSubview:self.backgroundView];
    [self addSubview:self.contentView];
    
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.returnBtn];
    [self.contentView addSubview:self.switchTitle];
    [self.contentView addSubview:self.switchBtn];
    
    [self.contentView addSubview:self.tableView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.backgroundView addGestureRecognizer:tapGes];
}

- (void)updateUI{
    self.backgroundView.frame = self.bounds;
    
    CGFloat contentView_H = 422;
    self.contentView.frame = CGRectMake(0, self.bounds.size.height - contentView_H, self.bounds.size.width, contentView_H);
    
    // return button
    CGFloat start_x = 16;
    CGFloat start_y = 16;
    self.returnBtn.frame = CGRectMake(start_x, start_y, 20, 20);
    
    // title
    start_x = (self.bounds.size.width - 270)/2 ;
    self.title.frame = CGRectMake(start_x, start_y, 270, 22);
    
    // switch title
    start_x = 36;
    start_y = 66;
    self.switchTitle.frame = CGRectMake(start_x, start_y, 80, 20);
    
    // switch button
    CGSize btn_size = CGSizeMake(51, 31);
    start_x = self.bounds.size.width - 18 - btn_size.width;
    start_y = 64;
    self.switchBtn.frame = CGRectMake(start_x, start_y, btn_size.width, btn_size.height);
    
    // table view
    start_y = 104;
    self.tableView.frame = CGRectMake(0, start_y, self.bounds.size.width, 422 - 104);
    
    [self drawCorners];
}

- (UIView *)backgroundView{
    if (!_backgroundView){
        _backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}

- (UIView *)contentView{
    if (!_contentView){
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#F7F8FA" alpha:1.0];
        
    }
    return _contentView;
}

-(UILabel *)title{
    if (!_title){
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:16];
        _title.text = @"字幕设置";
        _title.textAlignment = NSTextAlignmentCenter;
    }
    
    return _title;
}

- (UIButton *)returnBtn{
    if (!_returnBtn){
        _returnBtn = [[UIButton alloc] init];
        [_returnBtn setImage:[UIImage imageNamed:@"plv_skin_control_icon_subtitle_back"] forState:UIControlStateNormal];
        [_returnBtn addTarget:self action:@selector(retButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _returnBtn;
}

- (UILabel *)switchTitle{
    if (!_switchTitle){
        _switchTitle = [[UILabel alloc] init];
        _switchTitle.font = [UIFont systemFontOfSize:14];
        _switchTitle.text = @"显示字幕";
        _switchTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _switchTitle;
}

- (UISwitch *)switchBtn{
    if (!_switchBtn){
        _switchBtn = [[UISwitch alloc] init];
        [_switchBtn setOnTintColor:[PLVVodMediaColorUtil colorFromHexString:@"#3F76FC" alpha:1.0]];
        [_switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _switchBtn;
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#F7F8FA" alpha:1.0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PLVMediaPlayerSkinSubtitleSetCell class] forCellReuseIdentifier:REUSEID];
    }
    
    return _tableView;
}

#pragma mark -- [UITableViewDataSoure]

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.configModel.subtitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PLVMediaPlayerSkinSubtitleSetCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSEID forIndexPath:indexPath];
    if (!cell){
        cell = [[PLVMediaPlayerSkinSubtitleSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSEID];
    }
    PLVMediaPlayerSkinSubtitleItemModel *item = self.configModel.subtitles[indexPath.row];
    BOOL selected = NO;
    if (self.configModel.selIndex == indexPath.row){
        selected = YES;
    }
    [cell configSubtitleText:item.showName select:selected];

    return cell;
}

#pragma mark -- [UITableViewDelegate]
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 实时刷新字幕
    self.configModel.selIndex = indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinSubtitleSetView_SelectSubtitle)]){
        [self.delegate mediaPlayerSkinSubtitleSetView_SelectSubtitle];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark [button action]

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    [self hideSetView];
    
    // 隐藏父视图
    self.superview.hidden = YES;
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinSubtitleSetView_SelectSubtitle)]){
        [self.delegate mediaPlayerSkinSubtitleSetView_SelectSubtitle];
    }
}

- (void)retButtonClick:(UIButton *)btn{
    [self hideSetView];
}

#pragma mark [private]
- (void)hideSetView{
    self.hidden = YES;
}

- (void)drawCorners{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;

    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds
                                           byRoundingCorners:corners
                                                 cornerRadii:CGSizeMake(20, 20)].CGPath;
    self.contentView.layer.mask = maskLayer;
}

- (void)setConfigModel:(PLVMediaPlayerSubtitleConfigModel *)configModel{
    _configModel = configModel;
    
    if (!self.configModel.subtitlesEnabled){
        self.switchBtn.on = NO;
        self.tableView.hidden = YES;
    }
    else{
        self.switchBtn.on = YES;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

#pragma mark [public]
- (void)showWithConfigModel:(PLVMediaPlayerSubtitleConfigModel *)configModel{
    self.configModel = configModel;
    self.hidden = NO;
    //
    [self updateUI];
}

@end
