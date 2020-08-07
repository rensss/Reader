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

@interface RKPinView () <RKPinNumPadViewDelegate>

@property (nonatomic, strong) UILabel *promptLabel; /**< 提示*/
@property (nonatomic, strong) RKPinInputCirclesView *inputCirclesView; /**< 输入*/
@property (nonatomic, strong) RKPinNumPadView *numPad; /**< 键盘*/

@property (nonatomic, strong) UIButton *biometricAuth; /**< 生物特征认证*/
@property (nonatomic, strong) NSMutableString *input; /**< 输入字符*/

@end

@implementation RKPinView

- (instancetype)initWithDelegate:(id<RKPinViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _delegate = delegate;
        _input = [NSMutableString string];
        
        // title
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.numberOfLines = 0;
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:_promptLabel];
        [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.centerX.mas_equalTo(self);
        }];
        
        // PIN码
        _inputCirclesView = [[RKPinInputCirclesView alloc] initWithPinLength:[_delegate pinLengthForPinView:self]];
        [self addSubview:_inputCirclesView];
        [_inputCirclesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_promptLabel.mas_bottom).mas_offset(22.5);
            make.centerX.mas_equalTo(self);
        }];
        
        // Num pad
        _numPad = [[RKPinNumPadView alloc] initWithDelegate:self];
        [self addSubview:_numPad];
        [_numPad mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self);
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(_inputCirclesView.mas_bottom).mas_offset(41.5);
        }];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDelegate:nil];
}

#pragma mark - getting
- (UIColor *)promptColor {
    return self.promptLabel.textColor;
}

- (NSString *)promptTitle {
    return self.promptLabel.text;
}

#pragma mark - setting
- (void)setPromptColor:(UIColor *)promptColor {
    self.promptLabel.textColor = promptColor;
}

- (void)setPromptTitle:(NSString *)promptTitle {
    self.promptLabel.text = promptTitle;
}

#pragma mark - delegate
- (void)pinNumPadView:(RKPinNumPadView *)pinNumPadView numberTapped:(NSUInteger)number {
    
}



@end
