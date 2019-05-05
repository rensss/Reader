//
//  RKChapter.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKChapter.h"
#import <CoreText/CoreText.h>

@interface RKChapter ()

@property (nonatomic,strong) NSMutableArray *pageArray; /**< 分页内容 */

@end


@implementation RKChapter

- (instancetype)init {
    self = [super init];
    if (self) {
        _pageArray = [NSMutableArray array];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    [self paginateWithBounds:[RKUserConfig sharedInstance].readViewFrame];
}

- (void)paginateWithBounds:(CGRect)bounds {
    
    // 页码个数
    [self.pageArray removeAllObjects];
    // 内容显示属性
    NSAttributedString *attrString;
    // 当前指向的位置
    CTFramesetterRef frameSetter;
    // 显示路径
    CGPathRef path;
    // 内容字符串
    NSMutableAttributedString *attrStr;
    attrStr = [[NSMutableAttributedString alloc] initWithString:self.content];
    // 内容显示的属性(字号/字体/颜色...)
    NSDictionary *attribute = @{
                                NSFontAttributeName:[UIFont systemFontOfSize:[RKUserConfig sharedInstance].fontSize],
                                NSForegroundColorAttributeName:[UIColor colorWithHexString:[RKUserConfig sharedInstance].fontColor]
                                };
    [attrStr setAttributes:attribute range:NSMakeRange(0, attrStr.length)];
    attrString = [attrStr copy];
    
    frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    path = CGPathCreateWithRect(bounds, NULL);
    
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            ++samePlaceRepeatCount;
        } else {
            samePlaceRepeatCount = 0;
        }
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (self.pageArray.count == 0) {
                [self.pageArray addObject:@(currentOffset)];
            } else {
                NSUInteger lastOffset = [[self.pageArray lastObject] integerValue];
                if (lastOffset != currentOffset) {
                    [self.pageArray addObject:@(currentOffset)];
                }
            }
            break;
        }
        
        [self.pageArray addObject:@(currentOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        if ((range.location + range.length) != attrString.length) {
            currentOffset += range.length;
            currentInnerOffset += range.length;
        } else {
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
    self.allPages = self.pageArray.count;
}

/// 根据页码取出 当页内容
- (NSString *)stringOfPage:(NSUInteger)index {
    if (index >= self.pageArray.count) {
        index = self.pageArray.count - 1;
    }
    NSUInteger local = [self.pageArray[index] integerValue];
    NSUInteger length;
    if (index < self.allPages - 1 ) {
        length = [self.pageArray[index+1] integerValue] - [self.pageArray[index] integerValue];
    } else {
        length = self.content.length - [self.pageArray[index] integerValue];
    }
    return [self.content substringWithRange:NSMakeRange(local, length)];
}

@end
