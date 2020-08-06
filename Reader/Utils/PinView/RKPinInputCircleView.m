//
//  RKPinInputCircleView.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinInputCircleView.h"

@implementation RKPinInputCircleView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.cornerRadius = [[self class] diameter] / 2.0f;
        self.layer.borderWidth = 1.0f;
        
        [self tintColorDidChange];
    }
    return self;
}

- (void)tintColorDidChange {
    self.layer.borderColor = self.tintColor.CGColor;
}

- (void)setFilled:(BOOL)filled {
    self.backgroundColor = (filled) ? self.tintColor : [UIColor clearColor];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([[self class] diameter], [[self class] diameter]);
}

+ (CGFloat)diameter {
    return 16.0f;
}


@end
