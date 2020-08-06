//
//  RKPinNumPadView.h
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RKPinNumPadView;

@protocol RKPinNumPadViewDelegate <NSObject>

@required
- (void)pinNumPadView:(RKPinNumPadView *)pinNumPadView numberTapped:(NSUInteger)number;

@end

@interface RKPinNumPadView : UIView

@property (nonatomic, weak, nullable) id<RKPinNumPadViewDelegate> delegate;
@property (nonatomic, assign) BOOL hideLetters;

- (instancetype)initWithDelegate:(nullable id<RKPinNumPadViewDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
