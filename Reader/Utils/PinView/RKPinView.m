//
//  RKPinView.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinView.h"
#import "RKPinInputCirclesView.h"
#import "RKPinNumPadView.h"
#import "RKTouchFaceIDUtil.h"

@interface RKPinView () <RKPinNumPadViewDelegate>

@property (nonatomic, strong) UILabel *promptLabel; /**< 提示*/
@property (nonatomic, strong) RKPinInputCirclesView *inputCirclesView; /**< 输入*/
@property (nonatomic, strong) RKPinNumPadView *numPad; /**< 键盘*/

@property (nonatomic, strong) UIButton *biometricAuth; /**< 生物特征认证*/
@property (nonatomic, strong) UIButton *deleteBtn; /**< 删除按钮*/
@property (nonatomic, strong) UIButton *cancelBtn; /**< 取消按钮*/

@property (nonatomic, strong) NSMutableString *input; /**< 输入字符*/

@end

@implementation RKPinView

#pragma mark - init
- (instancetype)initWithDelegate:(id<RKPinViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _delegate = delegate;
        _input = [NSMutableString string];
        
        // title
        self.promptLabel = [[UILabel alloc] init];
        self.promptLabel.numberOfLines = 0;
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
        self.promptLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:self.promptLabel];
        [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.centerX.mas_equalTo(self);
        }];
        
        // PIN
        self.inputCirclesView = [[RKPinInputCirclesView alloc] initWithPinLength:[_delegate pinLengthForPinView:self]];
        [self addSubview:self.inputCirclesView];
        [self.inputCirclesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_promptLabel.mas_bottom).mas_offset(22.5);
            make.centerX.mas_equalTo(self);
        }];
        
        // Num pad
        self.numPad = [[RKPinNumPadView alloc] initWithDelegate:self];
        [self addSubview:self.numPad];
        [self.numPad mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(_inputCirclesView.mas_bottom).mas_offset(41.5);
        }];
        
        // auth
        [self addSubview:self.biometricAuth];
        [self.biometricAuth mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.numPad.mas_bottom).mas_offset(20);
            make.centerX.mas_equalTo(self);
        }];
        
        // cancel
        [self addSubview:self.cancelBtn];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self);
            make.top.mas_equalTo(self.biometricAuth.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.numPad.mas_left).mas_offset(22);
        }];
        
        // delete
        [self addSubview:self.deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.numPad.mas_bottom).mas_offset(-24);
            make.right.mas_equalTo(self.numPad.mas_right).mas_offset(-24);
        }];
        
        [self updateBottomButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDelegate:nil];
}

#pragma mark - delegate
- (void)pinNumPadView:(RKPinNumPadView *)pinNumPadView numberTapped:(NSUInteger)number {
    
    NSUInteger pinLength = [self.delegate pinLengthForPinView:self];
    
    if (self.input.length >= pinLength) return;
    
    [self.input appendString:[NSString stringWithFormat:@"%lu", (unsigned long)number]];
    DDLogVerbose(@"---- number:%lu input:%@",(unsigned long)number,self.input);

    [self.inputCirclesView fillCircleAtPosition:self.input.length - 1];
    
    [self updateBottomButton];
    
    if (self.input.length < pinLength) return;
    
    if ([self.delegate pinView:self isPinValid:self.input]) {
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate correctPinWasEnteredInPinView:self];
        });
    } else {
        [self.inputCirclesView shakeWithCompletion:^{
            [self resetInput];
            [self.delegate incorrectPinWasEnteredInPinView:self];
        }];
    }
}

#pragma mark - func
- (void)updateBottomButton {
    self.deleteBtn.hidden = (self.input.length == 0);
}

- (void)resetInput {
    self.input = [NSMutableString string];
    [self.inputCirclesView unfillAllCircles];
    [self updateBottomButton];
}

#pragma mark - 事件
- (void)requestBiometricAuth {
    __weak typeof(self) weakSelf = self;
    [RKTouchFaceIDUtil requestAuthenticationEvaluatePolicy:NO localizedReason:@"解锁" result:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if ([weakSelf.delegate respondsToSelector:@selector(correctPinWasEnteredInPinView:)]) {
                    [weakSelf.delegate correctPinWasEnteredInPinView:self];
                }
            }
        });
    }];
}

- (void)cancelClick {
    if ([self.delegate respondsToSelector:@selector(cancelButtonTappedInPinView:)]) {
        [self.delegate cancelButtonTappedInPinView:self];
    }
}

- (void)deleteClick {
    if (self.input.length > 0) {
        self.input = [NSMutableString stringWithString:[self.input substringToIndex:self.input.length-1]];
        [self.inputCirclesView unfillCircleAtPosition:self.input.length];
    }
    [self updateBottomButton];
}

#pragma mark - setting
- (void)setPromptColor:(UIColor *)promptColor {
    self.promptLabel.textColor = promptColor;
}

- (void)setPromptTitle:(NSString *)promptTitle {
    self.promptLabel.text = promptTitle;
}

- (void)setHideLetters:(BOOL)hideLetters {
    self.numPad.hideLetters = hideLetters;
}

- (void)setDisableCancel:(BOOL)disableCancel {
    if (self.disableCancel == disableCancel) return;
    _disableCancel = disableCancel;
    
    self.cancelBtn.hidden = disableCancel;
}

- (void)setDisableAuthentication:(BOOL)disableAuthentication {
    if (self.disableAuthentication == disableAuthentication) return;
    
    self.biometricAuth.hidden = disableAuthentication;
}

#pragma mark - getting
- (UIColor *)promptColor {
    return self.promptLabel.textColor;
}

- (NSString *)promptTitle {
    return self.promptLabel.text;
}

- (BOOL)hideLetters {
    return self.numPad.hideLetters;
}

- (UIButton *)biometricAuth {
    if (!_biometricAuth) {
        _biometricAuth = [[UIButton alloc] init];
        UIImage *image;
        if ([RKTouchFaceIDUtil canUseTouchID]) {
            image = [UIImage imageNamed:@"TouchID"];
        } else if ([RKTouchFaceIDUtil canUseFaceID]) {
            image = [UIImage imageNamed:@"FaceID"];
        }
        [_biometricAuth setImage:image forState:UIControlStateNormal];
        [_biometricAuth addTarget:self action:@selector(requestBiometricAuth) forControlEvents:UIControlEventTouchUpInside];
    }
    return _biometricAuth;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:@"cancel" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_cancelBtn setTitleColor:RKShowBtnTintColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setTitle:@"delete" forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_deleteBtn setTitleColor:RKShowBtnTintColor forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}


- (NSMutableString *)input {
    if (!_input) {
        _input = [NSMutableString string];
    }
    return _input;
}

@end
