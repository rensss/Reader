//
//  RKPinNumButton.h
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RKPinNumButton : UIButton

@property (nonatomic, readonly, assign) NSUInteger number;
@property (nonatomic, readonly, copy, nullable) NSString *letters;

- (instancetype)initWithNumber:(NSUInteger)number letters:(nullable NSString *)letters NS_DESIGNATED_INITIALIZER;

+ (CGFloat)diameter;

@end

NS_ASSUME_NONNULL_END
