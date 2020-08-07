//
//  RKPinNumPadView.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinNumPadView.h"
#import "RKPinNumButton.h"

@interface RKPinNumPadView ()

@property (nonatomic, assign) CGFloat hPadding;
@property (nonatomic, assign) CGFloat vPadding;

@property (nonatomic, strong) NSArray *lettersArray; /**< 字母*/

@end

@implementation RKPinNumPadView

- (instancetype)initWithDelegate:(id<RKPinNumPadViewDelegate>)delegate {
    self = [self init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hPadding = 20.0f;
        _vPadding = 13.0f;
        
        [self setupViews];
    }
    return self;
}

#pragma mark - func
- (void)setupViews {
    // remove existing views
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    NSMutableDictionary *rowViews = [NSMutableDictionary dictionary];
    
    for (NSUInteger row = 0; row < 4; row++) {
        UIView *rowView = [[UIView alloc] init];
        rowView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:rowView];
        [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (row == 3) {
                make.centerX.mas_equalTo(self);
                make.bottom.mas_equalTo(self.mas_bottom);
            } else {
                make.left.right.mas_equalTo(self);
            }
            make.top.mas_equalTo(self).mas_offset(row*(_vPadding+[RKPinNumButton diameter]));
        }];
        
        NSString *rowName = [NSString stringWithFormat:@"row%lu", (unsigned long)row];
        rowViews[rowName] = rowView;
        
        NSMutableDictionary *buttonViews = [NSMutableDictionary dictionary];
        
        for (NSUInteger col = 0; col < 3; col++) {
            if (row == 3 && col != 1) {
                // only one button on last row
                continue;
            }
            
            NSUInteger number = (row < 3) ? row * 3 + col + 1 : 0;
            
            NSString *letter;
            if (row != 3) {
                letter = self.lettersArray[row][col];
            }
            
            RKPinNumButton *button = [[RKPinNumButton alloc] initWithNumber:number letters:letter];
            
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.backgroundColor = self.backgroundColor;
            [button addTarget:self action:@selector(numberButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(rowView);
                if (row == 3 && col == 1) {
                    make.left.mas_equalTo(rowView).mas_offset(_hPadding);
                    make.right.mas_equalTo(rowView).mas_offset(-_hPadding);
                } else {
                    make.left.mas_equalTo(rowView).mas_offset(_hPadding+col*(_hPadding+[RKPinNumButton diameter]));
                    if (col == 2) {
                        make.right.mas_equalTo(self).mas_offset(-_hPadding);
                    }
                }
            }];
            
            NSString *buttonName = [NSString stringWithFormat:@"button%lu%lu", (unsigned long)row, (unsigned long)col];
            buttonViews[buttonName] = button;
        }
    }
    
}

- (void)numberButtonTapped:(id)sender {
    [self.delegate pinNumPadView:self numberTapped:((RKPinNumButton *)sender).number];
}

#pragma mark - getting
- (NSArray *)lettersArray {
    if (!_lettersArray) {
        _lettersArray = @[
            @[
                @" ", // 占位
                @"ABC",
                @"DEF"
            ],
            @[
                @"GHI",
                @"JKL",
                @"MNO"
            ],
            @[
                @"PQRS",
                @"TUV",
                @"WXYZ"
            ],
        ];
    }
    return _lettersArray;
}

@end
