//
//  ShareViewController.m
//  ReaderShare
//
//  Created by Rzk on 2020/5/26.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "ShareViewController.h"
#import <CoreServices/CoreServices.h>

#define kAPPGroupName @"group.smart.test"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ShareViewController ()



@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 100, 100, 45)];
    cancelButton.backgroundColor = [UIColor redColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 100 + 45 + 20, 100, 45)];
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
                
//                NSString *registered = obj.registeredTypeIdentifiers.firstObject;
//                CFStringRef registeredType = (__bridge CFStringRef)registered;
//                BOOL isContain = UTTypeConformsTo(registeredType, kUTTypeText);
                
                NSString *fileType = @"public.plain-text";
                if ([obj hasItemConformingToTypeIdentifier:fileType]) {
//                    [obj loadDataRepresentationForTypeIdentifier:fileType completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
//                        NSURL *groupURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:kAPPGroupName];
//
//                        [data writeToURL:[groupURL URLByAppendingPathComponent:@""] atomically:YES];
//
//                    }];
                    
                    [obj loadItemForTypeIdentifier:fileType options:nil completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSLog(@"item:%@\n", [item class]);

                        NSURL *groupURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:kAPPGroupName];
                        
                        NSURL *itemUrl = item;
                        NSString *path = groupURL.path;
                        NSString *name = itemUrl.lastPathComponent;
                        NSString *appendingPath = [NSString stringWithFormat:@"%@", name];
                        NSData *fileData = [NSData dataWithContentsOfURL:item];
                        NSURL *newUrl = [groupURL URLByAppendingPathComponent:appendingPath];
                        [fileData writeToURL:newUrl atomically:YES];
                        
                        NSLog(@"---- \n%@\n%@\n%@\n%@", path, name, appendingPath, newUrl);
                        
                        [self didSelectPost];
//                        NSError *fileError;
//                        [NSFileManager.defaultManager moveItemAtURL:item toURL:groupURL error:&fileError];
//                        if (fileError) {
//                            NSLog(@"%@", fileError);
//                        }
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

- (void)cancelBtnClickHandler:(id)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
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
