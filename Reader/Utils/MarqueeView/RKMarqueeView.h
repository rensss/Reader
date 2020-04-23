//
//  RKMarqueeView.h
//  Reader
//
//  Created by Rzk on 2020/4/23.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKMarqueeView;
typedef NS_ENUM(NSUInteger, RKMarqueeViewDirection) {
    RKMarqueeViewDirectionUpward,   // scroll from bottom to top
    RKMarqueeViewDirectionLeftward  // scroll from right to left
};

#pragma mark - RKMarqueeViewDelegate
@protocol RKMarqueeViewDelegate <NSObject>

- (NSUInteger)numberOfDataForMarqueeView:(RKMarqueeView *)marqueeView;
- (void)createItemView:(UIView *)itemView forMarqueeView:(RKMarqueeView *)marqueeView;
- (void)updateItemView:(UIView *)itemView atIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView;

@optional

- (NSUInteger)numberOfVisibleItemsForMarqueeView:(RKMarqueeView *)marqueeView;   // only for [RKMarqueeViewDirectionUpward]
- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView;   // only for [RKMarqueeViewDirectionLeftward]
- (CGFloat)itemViewHeightAtIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView;   // only for [RKMarqueeViewDirectionUpward] and [useDynamicHeight = YES]
- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView;

@end

@interface RKMarqueeView : UIView

@property (nonatomic, weak) id<RKMarqueeViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeIntervalPerScroll;
@property (nonatomic, assign) NSTimeInterval timeDurationPerScroll; // only for [RKMarqueeViewDirectionUpward] and [useDynamicHeight = NO]
@property (nonatomic, assign) BOOL useDynamicHeight;    // only for [RKMarqueeViewDirectionUpward]
@property (nonatomic, assign) float scrollSpeed;    // only for [RKMarqueeViewDirectionLeftward] or [RKMarqueeViewDirectionUpward] with [useDynamicHeight = YES]
@property (nonatomic, assign) float itemSpacing;    // only for [RKMarqueeViewDirectionLeftward]
@property (nonatomic, assign) BOOL stopWhenLessData;    // do not scroll when all data has been shown
@property (nonatomic, assign) BOOL clipsToBounds;
@property (nonatomic, assign, getter=isTouchEnabled) BOOL touchEnabled;
@property (nonatomic, assign) RKMarqueeViewDirection direction;

- (instancetype)initWithDirection:(RKMarqueeViewDirection)direction;
- (instancetype)initWithFrame:(CGRect)frame direction:(RKMarqueeViewDirection)direction;
- (void)reloadData;
- (void)start;
- (void)pause;

@end

#pragma mark - RKMarqueeViewTouchResponder(Private)
@protocol RKMarqueeViewTouchResponder <NSObject>

- (void)touchesBegan;
- (void)touchesEndedAtPoint:(CGPoint)point;
- (void)touchesCancelled;

@end

#pragma mark - RKMarqueeViewTouchReceiver(Private)
@interface RKMarqueeViewTouchReceiver : UIView

@property (nonatomic, weak) id<RKMarqueeViewTouchResponder> touchDelegate;

@end

#pragma mark - RKMarqueeItemView(Private)
@interface RKMarqueeItemView : UIView   // RKMarqueeItemView's [tag] is the index of data source. if none data source then [tag] is -1

@property (nonatomic, assign) BOOL didFinishCreate;
@property (nonatomic, assign) CGFloat width;    // cache the item width, only for [RKMarqueeViewDirectionLeftward]
@property (nonatomic, assign) CGFloat height;   // cache the item height, only for [RKMarqueeViewDirectionUpward]

- (void)clear;

@end
