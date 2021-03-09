//
//  ShareViewController.m
//  ReaderShare
//
//  Created by Rzk on 2020/5/26.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "ShareViewController.h"

#define kAPPGroupName @"group.micsoft.Reader"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ShareViewController ()



@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 100, 100, 45)];
    addButton.backgroundColor = [UIColor redColor];
    [addButton setTitle:@"添加" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn {
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /*
         attributedTitle:(null)
         attributedContentText:(null)
         attachments:(
             "<NSItemProvider: 0x2839e8e00> {
                types = (\n    \"public.plain-text\",
                        \n    \"public.file-url\"\n)
                }"
         */
        if ([obj isKindOfClass:[NSExtensionItem class]]) {
            NSExtensionItem *item = obj;
            NSLog(@"\nidx:%lu\nattributedTitle:%@\nattributedContentText:%@\nattachments:%@", (unsigned long)idx, item.attributedTitle, item.attributedContentText, item.attachments);
            
            [item.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
                    [obj loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSLog(@"item:%@\n", [item class]);
                        
                         NSURL *groupURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:kAPPGroupName];
                        [NSFileManager.defaultManager moveItemAtURL:item toURL:groupURL error:nil];
                    }];
                }
                if ([obj hasItemConformingToTypeIdentifier:@"public.file-url"]) {
                    [obj loadItemForTypeIdentifier:@"public.file-url" options:nil completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSLog(@"item:%@\n", [item class]);
                    }];
                }
            }];
            
        }
//        *stop = YES;
    }];

}


#pragma mark - system func
- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
