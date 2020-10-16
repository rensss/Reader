//
//  RKBackViewController.m
//  Reader
//
//  Created by Rzk on 2020/10/16.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKBackViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RKBackViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *backgroundImage;

- (UIImage *)captureView:(UIView *)view;

@end

@implementation RKBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_offset(0);
    }];
    [self.imageView setImage:self.backgroundImage];
    
//    UIImage *image = [UIImage imageNamed:[RKUserConfig sharedInstance].bgImageName];
//    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
//        image = [UIImage imageWithColor:[UIColor blackColor]];
//    }
//    self.view.layer.contents = (id)image.CGImage;
//    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
}

- (void)updateWithViewController:(UIViewController *)viewController {
    self.backgroundImage = [self captureView:viewController.view];
}

- (UIImage *)captureView:(UIView *)view {
    CGRect rect = view.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, rect.size.width, 0.0);
    CGContextConcatCTM(context,transform);
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - getting
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;;
}

@end
