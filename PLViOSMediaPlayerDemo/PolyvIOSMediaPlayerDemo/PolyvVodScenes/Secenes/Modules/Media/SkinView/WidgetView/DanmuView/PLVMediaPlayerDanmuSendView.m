//
//  PLVMediaPlayerDanmuSendView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/6.
//

#import "PLVMediaPlayerDanmuSendView.h"
#if __has_include(<PLVVodDanmu/PLVVodDanmu.h>)
#import <PLVVodDanmu/PLVVodDanmu.h>
#else
#import "PLVVodDanmu.h"
#endif

@interface PLVMediaPlayerDanmuSendView()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *danmuTextField;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIView *settingContentView;

@property (nonatomic, strong) UILabel *colorLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *fontSizeLabel;

@property (nonatomic, strong) NSMutableArray<UIButton *> *colorButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> *typeButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> *fontSizeButtons;

@property (nonatomic, assign) NSUInteger danmuColorHex;
@property (nonatomic, assign) int danmuFontSize;
@property (nonatomic, assign) NSInteger danmuMode;

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *modes;
@property (nonatomic, strong) NSArray *fontSizes;

@property (nonatomic, assign) CGFloat keyboardHeight; /// 键盘高度

@property (nonatomic, strong) UIView *gestureMaskView;

@end

@implementation PLVMediaPlayerDanmuSendView

#pragma mark - init & dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self setupUI];
    }
    return self;
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 监听横竖屏切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    _colors = @[@(0xffffff), @(0xf44436), @(0xe239ff),
                @(0x53c057), @(0x2398ff), @(0xffd758)];
    _modes = @[@(PLVVodDanmuModeRoll), @(PLVVodDanmuModeTop), @(PLVVodDanmuModeBottom)];
    _fontSizes = @[@16, @18, @24];
    
    self.danmuColorHex = 0xffffff;
    self.danmuFontSize = 16;
    self.danmuMode = PLVVodDanmuModeRoll;
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Lazy Load

- (UITextField *)danmuTextField {
    if (!_danmuTextField) {
        _danmuTextField = [[UITextField alloc] init];
        _danmuTextField.backgroundColor = [UIColor colorWithRed:0x2c/255.0 green:0x35/255.0 blue:0x42/255.0 alpha:1.0];
        _danmuTextField.textColor = [UIColor whiteColor];
        _danmuTextField.font = [UIFont systemFontOfSize:14];
        _danmuTextField.placeholder = @"说点什么...";
        _danmuTextField.layer.cornerRadius = 16;
        _danmuTextField.layer.masksToBounds = YES;
        _danmuTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
        _danmuTextField.leftViewMode = UITextFieldViewModeAlways;
        _danmuTextField.returnKeyType = UIReturnKeySend;
        _danmuTextField.delegate = self;
    }
    return _danmuTextField;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
        [_settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_settingButton setImage:[UIImage imageNamed:@"plv_skin_icon_danmu_setting"] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

- (UIView *)settingContentView {
    if (!_settingContentView) {
        _settingContentView = [[UIView alloc] init];
        _settingContentView.backgroundColor = [UIColor colorWithRed:0x1a/255.0 green:0x21/255.0 blue:0x2e/255.0 alpha:1.0];

    }
    return _settingContentView;
}

- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [[UILabel alloc] init];
        _colorLabel.text = @"弹幕颜色";
        _colorLabel.textColor = [UIColor whiteColor];
        _colorLabel.font = [UIFont systemFontOfSize:14];
    }
    return _colorLabel;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.text = @"弹幕类型";
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.font = [UIFont systemFontOfSize:14];
    }
    return _typeLabel;
}

- (UILabel *)fontSizeLabel {
    if (!_fontSizeLabel) {
        _fontSizeLabel = [[UILabel alloc] init];
        _fontSizeLabel.text = @"字体大小";
        _fontSizeLabel.textColor = [UIColor whiteColor];
        _fontSizeLabel.font = [UIFont systemFontOfSize:14];
    }
    return _fontSizeLabel;
}

- (UIView *)gestureMaskView {
    if (!_gestureMaskView) {
        _gestureMaskView = [[UIView alloc] init];
        _gestureMaskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureMaskViewTapped:)];
        [_gestureMaskView addGestureRecognizer:tapGesture];
    }
    return _gestureMaskView;
}

#pragma mark - Property

- (NSString *)danmuContent {
    return self.danmuTextField.text;
}

#pragma mark - UI Setup

- (void)setupUI {
        
    [self addSubview:self.gestureMaskView];
    [self addSubview:self.danmuTextField];
    [self addSubview:self.settingButton];
    [self addSubview:self.settingContentView];
    
    [self.settingContentView addSubview:self.colorLabel];
    [self.settingContentView addSubview:self.typeLabel];
    [self.settingContentView addSubview:self.fontSizeLabel];
    
    // 创建并添加颜色按钮
    self.colorButtons = [NSMutableArray array];
    for (int i = 0; i < _colors.count; i++) {
        UIButton *colorButton = [self createColorButtonWithIndex:i];
        [self.settingContentView addSubview:colorButton];
        [self.colorButtons addObject:colorButton];
    }
    
    // 创建并添加类型按钮
    self.typeButtons = [NSMutableArray array];
    NSArray *typeTitles = @[@"滚动", @"顶部", @"底部"];
    for (int i = 0; i < typeTitles.count; i++) {
        UIButton *typeButton = [self createTextButtonWithTitle:typeTitles[i] action:@selector(typeButtonAction:)];
        [self.settingContentView addSubview:typeButton];
        [self.typeButtons addObject:typeButton];
        if (i == 0) {
            typeButton.selected = YES;
            typeButton.backgroundColor = [UIColor colorWithRed:0x3b/255.0 green:0x9e/255.0 blue:0xff/255.0 alpha:1.0];
        }
    }
    
    // 创建并添加字体大小按钮
    self.fontSizeButtons = [NSMutableArray array];
    for (int i = 0; i < _fontSizes.count; i++) {
        NSString *title = [NSString stringWithFormat:@"%@", _fontSizes[i]];
        UIButton *fontButton = [self createTextButtonWithTitle:title action:@selector(fontSizeButtonAction:)];
        [self.settingContentView addSubview:fontButton];
        [self.fontSizeButtons addObject:fontButton];
        if (i == 0) {
            fontButton.selected = YES;
            fontButton.backgroundColor = [UIColor colorWithRed:0x3b/255.0 green:0x9e/255.0 blue:0xff/255.0 alpha:1.0];
        }
    }

    self.keyboardHeight = 200;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gestureMaskView.frame = self.bounds;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat leftMargin = 15;
    CGFloat rightMargin = 15;
        
    // 设置面板布局
    CGFloat settingHeight = self.keyboardHeight ;
    CGFloat settingTop = CGRectGetHeight(self.bounds) - settingHeight;
    self.settingContentView.frame = CGRectMake(0, settingTop, width, settingHeight);
    
    // 输入框和设置按钮布局
    CGFloat settingBtnWidth = 32;
    CGFloat settingBtnHeight = 32;
    CGFloat topMargin = settingTop - settingBtnHeight;
    self.settingButton.frame = CGRectMake(width - rightMargin - settingBtnWidth, topMargin, settingBtnWidth, settingBtnHeight);
    self.danmuTextField.frame = CGRectMake(leftMargin, topMargin, CGRectGetMinX(self.settingButton.frame) - leftMargin - 8, settingBtnHeight);
    
    [self layoutSettingContent];
}

- (void)layoutSettingContent {
    CGFloat contentWidth = CGRectGetWidth(self.settingContentView.bounds);
    CGFloat labelWidth = 80;
    CGFloat buttonSize = 28;
    CGFloat buttonSpacing = 12;
    CGFloat labelButtonGap = 12;
    CGFloat rowSpacing = 16;
    
    // 第一行：弹幕颜色 - 居中布局
    CGFloat colorButtonsWidth = self.colorButtons.count * buttonSize + (self.colorButtons.count - 1) * buttonSpacing;
    CGFloat colorRowWidth = labelWidth + labelButtonGap + colorButtonsWidth;
    CGFloat colorRowStartX = (contentWidth - colorRowWidth) / 2.0;
    
    self.colorLabel.frame = CGRectMake(colorRowStartX, 20, labelWidth, 28);
    CGFloat colorStartX = CGRectGetMaxX(self.colorLabel.frame) + labelButtonGap;
    for (int i = 0; i < self.colorButtons.count; i++) {
        UIButton *btn = self.colorButtons[i];
        btn.frame = CGRectMake(colorStartX + i * (buttonSize + buttonSpacing), 20, buttonSize, buttonSize);
    }
    
    // 第二行：弹幕类型 - 居中布局
    CGFloat typeY = CGRectGetMaxY(self.colorLabel.frame) + rowSpacing;
    CGFloat typeBtnWidth = 56;
    CGFloat typeButtonsWidth = self.typeButtons.count * typeBtnWidth + (self.typeButtons.count - 1) * buttonSpacing;
    CGFloat typeRowWidth = labelWidth + labelButtonGap + typeButtonsWidth;
    CGFloat typeRowStartX = (contentWidth - typeRowWidth) / 2.0;
    
    self.typeLabel.frame = CGRectMake(typeRowStartX, typeY, labelWidth, 28);
    CGFloat typeStartX = CGRectGetMaxX(self.typeLabel.frame) + labelButtonGap;
    for (int i = 0; i < self.typeButtons.count; i++) {
        UIButton *btn = self.typeButtons[i];
        btn.frame = CGRectMake(typeStartX + i * (typeBtnWidth + buttonSpacing), typeY, typeBtnWidth, 28);
    }
    
    // 第三行：字体大小 - 居中布局
    CGFloat fontSizeY = CGRectGetMaxY(self.typeLabel.frame) + rowSpacing;
    CGFloat fontBtnWidth = 56;
    CGFloat fontButtonsWidth = self.fontSizeButtons.count * fontBtnWidth + (self.fontSizeButtons.count - 1) * buttonSpacing;
    CGFloat fontRowWidth = labelWidth + labelButtonGap + fontButtonsWidth;
    CGFloat fontRowStartX = (contentWidth - fontRowWidth) / 2.0;
    
    self.fontSizeLabel.frame = CGRectMake(fontRowStartX, fontSizeY, labelWidth, 28);
    CGFloat fontStartX = CGRectGetMaxX(self.fontSizeLabel.frame) + labelButtonGap;
    for (int i = 0; i < self.fontSizeButtons.count; i++) {
        UIButton *btn = self.fontSizeButtons[i];
        btn.frame = CGRectMake(fontStartX + i * (fontBtnWidth + buttonSpacing), fontSizeY, fontBtnWidth, 28);
    }
}

#pragma mark - Helper Methods

- (UIButton *)createColorButtonWithIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 14;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor clearColor].CGColor;
    
    NSUInteger colorHex = [_colors[index] unsignedIntegerValue];
    UIColor *color = [UIColor colorWithRed:((colorHex >> 16) & 0xFF)/255.0
                                     green:((colorHex >> 8) & 0xFF)/255.0
                                      blue:(colorHex & 0xFF)/255.0
                                     alpha:1.0];
    button.backgroundColor = color;
    [button addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (index == 0) {
        button.selected = YES;
        button.layer.borderColor = [UIColor colorWithRed:0x3b/255.0 green:0x9e/255.0 blue:0xff/255.0 alpha:1.0].CGColor;
    }
    
    return button;
}

- (UIButton *)createTextButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0x99/255.0 green:0xa5/255.0 blue:0xb5/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.backgroundColor = [UIColor colorWithRed:0x2c/255.0 green:0x35/255.0 blue:0x42/255.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.superview) {
        return;
    }
   
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (!self.superview) {
        return;
    }

    NSDictionary *userInfo = [notification userInfo];
//    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.settingButton.selected = NO;
    self.keyboardHeight = CGRectGetHeight(keyboardRect);
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.superview) {
        return;
    }
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (!self.superview) {
        return;
    }
    
    // 回到竖屏时，取消键盘
    [self.danmuTextField resignFirstResponder];
}

#pragma mark - action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.danmuTextField resignFirstResponder];
}

- (void)settingButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.danmuTextField resignFirstResponder];
    } else {
        [self.danmuTextField becomeFirstResponder];
    }

}

- (void)colorButtonAction:(UIButton *)sender {
    for (UIButton *button in self.colorButtons) {
        button.selected = NO;
        button.layer.borderColor = [UIColor clearColor].CGColor;
    }
    sender.selected = YES;
    sender.layer.borderColor = [UIColor colorWithRed:0x3b/255.0 green:0x9e/255.0 blue:0xff/255.0 alpha:1.0].CGColor;
    
    NSUInteger index = [self.colorButtons indexOfObject:sender];
    if (index < _colors.count) {
        self.danmuColorHex = [_colors[index] unsignedIntegerValue];
    }
}

- (void)typeButtonAction:(UIButton *)sender {
    for (UIButton *button in self.typeButtons) {
        button.selected = NO;
        button.backgroundColor = [UIColor colorWithRed:0x2c/255.0 green:0x35/255.0 blue:0x42/255.0 alpha:1.0];
    }
    sender.selected = YES;
    sender.backgroundColor = [UIColor colorWithRed:0x3b/255.0 green:0x9e/255.0 blue:0xff/255.0 alpha:1.0];
    
    NSUInteger index = [self.typeButtons indexOfObject:sender];
    if (index < _modes.count) {
        self.danmuMode = [_modes[index] integerValue];
    }
}

- (void)fontSizeButtonAction:(UIButton *)sender {
    for (UIButton *button in self.fontSizeButtons) {
        button.selected = NO;
        button.backgroundColor = [UIColor colorWithRed:0x2c/255.0 green:0x35/255.0 blue:0x42/255.0 alpha:1.0];
    }
    sender.selected = YES;
    sender.backgroundColor = [UIColor colorWithRed:0x3b/255.0 green:0x9e/255.0 blue:0xff/255.0 alpha:1.0];
    
    NSUInteger index = [self.fontSizeButtons indexOfObject:sender];
    if (index < _fontSizes.count) {
        self.danmuFontSize = [_fontSizes[index] intValue];
    }
}

- (void)gestureMaskViewTapped:(UITapGestureRecognizer *)gesture {
    [self removeFromSuperview];
}

- (void)didMoveToSuperview {
    if (self.superview) {
        self.danmuTextField.text = nil;
        [self.danmuTextField becomeFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLVVodDanmuWillSendNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PLVVodDanmuEndSendNotification object:self];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *content = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (content.length > 0 && self.delegate && [self.delegate respondsToSelector:@selector(danmuSendView:didSendDanmuWithContent:colorHex:fontSize:mode:)]) {
        [self.delegate danmuSendView:self didSendDanmuWithContent:content colorHex:self.danmuColorHex fontSize:self.danmuFontSize mode:self.danmuMode];
        textField.text = nil;
        [textField resignFirstResponder];
    }
    return YES;
}

@end
