//
//  RKReadView.m
//  Reader
//
//  Created by Rzk on 2019/4/26.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadView.h"

@implementation RKReadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - drawRect
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // 步骤 1
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 步骤 2
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    // 步骤 3
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    // 步骤 4
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSDictionary *attribute = @{
                                NSFontAttributeName:[UIFont systemFontOfSize:[RKUserConfig sharedInstance].fontSize],
                                NSForegroundColorAttributeName:[UIColor colorWithHexString:[RKUserConfig sharedInstance].fontColor]
                                };
    [attributedString setAttributes:attribute range:NSMakeRange(0, self.content.length)];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [attributedString length]), path, NULL);
    // 步骤 5
    CTFrameDraw(frame, context);
    // 步骤 6
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end
