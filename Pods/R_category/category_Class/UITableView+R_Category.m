//
//  UITableView+R_Category.m
//  R_category
//
//  Created by MBP on 2018/1/26.
//  Copyright © 2018年 rzk. All rights reserved.
//

#import "UITableView+R_Category.h"
#import <objc/runtime.h>

@implementation UITableView (R_Category)

#pragma mark - 交换方法
+ (void)load {
    //交换reloadData方法
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(reloadData)), class_getInstanceMethod(self, @selector(r_reloadData)));
    
    //交换insertSections方法
    method_exchangeImplementations(class_getInstanceMethod(self,@selector(insertSections:withRowAnimation:)),class_getInstanceMethod(self,@selector(r_insertSections:withRowAnimation:)));
    
    //交换insertRowsAtIndexPaths方法
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(insertRowsAtIndexPaths:withRowAnimation:)),  class_getInstanceMethod(self, @selector(r_insertRowsAtIndexPaths:withRowAnimation:)));
    
    //交换deleteSections方法
    method_exchangeImplementations(class_getInstanceMethod(self,@selector(deleteSections:withRowAnimation:)),class_getInstanceMethod(self,@selector(r_deleteSections:withRowAnimation:)));
    
    //交换deleteRowsAtIndexPaths方法
    method_exchangeImplementations(class_getInstanceMethod(self,@selector(deleteRowsAtIndexPaths:withRowAnimation:)),class_getInstanceMethod(self,@selector(r_deleteRowsAtIndexPaths:withRowAnimation:)));
    
    //交换刷新分区方法
    method_exchangeImplementations(class_getInstanceMethod(self,@selector(reloadSections:withRowAnimation:)),class_getInstanceMethod(self,@selector(r_reloadSections:withRowAnimation:)));
}

//reloadData
- (void)r_reloadData {
    [self r_reloadData];
    
    [self reloadEmptyImageView];
}

//insert
- (void)r_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self r_insertSections:sections withRowAnimation:animation];
    [self reloadEmptyImageView];
}

- (void)r_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self r_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self reloadEmptyImageView];
}

// delete
- (void)r_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self r_deleteSections:sections withRowAnimation:animation];
    [self reloadEmptyImageView];
}

- (void)r_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self r_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self reloadEmptyImageView];
}

- (void)r_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self r_reloadSections:sections withRowAnimation:animation];
    [self reloadEmptyImageView];
}

#pragma mark - setter/getter
- (void)setEmptyImage:(UIImage *)emptyImage {
    objc_setAssociatedObject(self, @selector(emptyImage), emptyImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self reloadEmptyImageView];
}

- (UIImage *)emptyImage {
    return objc_getAssociatedObject(self, @selector(emptyImage));
}

#pragma mark - 刷新空数据显示
- (void)reloadEmptyImageView {
    
    UIView *emptyview = [self viewWithTag:110000];
    [emptyview removeFromSuperview];
    
    if (!self.emptyImage) {
        return;
    }
    
    //计算行数
    NSInteger rows = 0;
    for (int i = 0; i <  self.numberOfSections; i ++) {
        rows += [self numberOfRowsInSection:i];
    }
    
    //如果没有数据 或者字符串为空 就不显示
    if (rows > 0) {
        return;
    }
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.emptyImage.size.width, self.emptyImage.size.height)];
    emptyImageView.tag = 110000;
    emptyImageView.image = self.emptyImage;
    emptyImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self addSubview:emptyImageView];
}

@end
