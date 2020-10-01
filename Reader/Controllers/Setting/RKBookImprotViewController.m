//
//  RKBookImprotViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKBookImprotViewController.h"
#import <GCDWebUploader.h>

@interface RKBookImprotViewController () <GCDWebUploaderDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDWebUploader *webUploader; /**< 网页上传*/

@property (nonatomic, strong) UILabel *addressLabel; /**< 地址*/
@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/

@end

@implementation RKBookImprotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"导入";
    
    [self.webUploader start];
    DDLogDebug(@"Visit %@ in your web browser", self.webUploader.serverURL);
    
    [self initUI];
}

- (void)dealloc {
    [self.webUploader stop];
}

#pragma mark - func
- (void)initUI {
    
    if (self.showType == RKImprotShowTypePresent) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeClick)];
        self.navigationItem.leftBarButtonItem = item;
    }
    
    UILabel *addressLabel = [UILabel new];
    self.addressLabel = addressLabel;
    [self.view addSubview:addressLabel];
    addressLabel.text = @"地址";
    addressLabel.font = [UIFont systemFontOfSize:15];
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.userInteractionEnabled = YES;
    [addressLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddress:)]];
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    UITableView *tableView = [UITableView new];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addressLabel.mas_bottom);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    
    // 设置label内容
    if (self.webUploader.serverURL.absoluteString) {
        NSString *url = [NSString stringWithFormat:@"浏览器访问->%@",self.webUploader.serverURL.absoluteString];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:url];
        NSRange urlRange = [url rangeOfString:self.webUploader.serverURL.absoluteString];
        [attributedStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:urlRange];
        [attributedStr addAttribute:NSUnderlineColorAttributeName value:[UIColor blueColor] range:urlRange];
        self.addressLabel.attributedText = attributedStr;
    } else {
        self.addressLabel.text = @"GCDWebUploader init failed!";
    }
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

#pragma mark - 点击
- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapAddress:(UITapGestureRecognizer *)gesture {
    
    UIActivityViewController *acitivityVC = [[UIActivityViewController alloc] initWithActivityItems:@[ self.webUploader.serverURL.absoluteString ] applicationActivities:nil];
    if (kIsPad) {
        acitivityVC.popoverPresentationController.sourceView = gesture.view;
        acitivityVC.popoverPresentationController.sourceRect = gesture.view.frame;
    }
    [[RKUtils topMostController] presentViewController:acitivityVC animated:YES completion:nil];
}

#pragma mark - 代理
#pragma mark -- GCDWebUploaderDelegate
/**
 *  This method is called whenever a file has been downloaded.
 */
- (void)webUploader:(GCDWebUploader*)uploader didDownloadFileAtPath:(NSString*)path {
    DDLogDebug(@"didDownloadFileAtPath---->\n");
    [self reloadTableView];
}

/**
 *  This method is called whenever a file has been uploaded.
 */
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    DDLogDebug(@"didUploadFileAtPath---->\n %@",path);
    
    // 截取书名 带扩展
    NSString *title = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",uploader.uploadDirectory]  withString:@""];
    
    // 保存&解析
    [[RKFileManager shareInstance] saveBookWithPath:title];
    
    NSString *alertMessageStr = [NSString stringWithFormat:@"%@ 上传成功",title];
    RKAlertMessage(alertMessageStr,self.view);
    
    [self.dataArray addObject:title];
    
    [self reloadTableView];
}

/**
 *  This method is called whenever a file or directory has been moved.
 */
- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    DDLogDebug(@"didMoveItemFromPath---->\n");
    [self reloadTableView];
}

/**
 *  This method is called whenever a file or directory has been deleted.
 */
- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    DDLogDebug(@"didDeleteItemAtPath---->\n");
    // 截取书名 带扩展
    NSString *name = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",uploader.uploadDirectory]  withString:@""];
    // 更新首页数据
    [[RKFileManager shareInstance] deleteBookWithName:name];
    
    [self.dataArray removeObject:name];
    
    [self reloadTableView];
}

/**
 *  This method is called whenever a directory has been created.
 */
- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    DDLogDebug(@"didCreateDirectoryAtPath---->\n");
    [self reloadTableView];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *name = [self.dataArray[indexPath.row] componentsSeparatedByString:@"/"].lastObject;
    cell.textLabel.text = name;
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getting
- (GCDWebUploader *)webUploader {
    if (!_webUploader) {
        _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:kBookSavePath];
        _webUploader.delegate = self;
        // 允许上传的文件类型
        _webUploader.allowedFileExtensions = @[@"txt",@"TXT"];
        // 页面上的提示
        _webUploader.prologue = @"点击Upload Files... 选择上传文件 ps:仅支持txt格式文件";
        _webUploader.epilogue = @"拖拽文件到此处上传";
        _webUploader.footer = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    }
    return _webUploader;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSFileManager *manager = [NSFileManager defaultManager];
        //获取数据
        NSArray *files = [manager contentsOfDirectoryAtPath:kBookSavePath error:nil];
        _dataArray = [NSMutableArray arrayWithArray:files];
    }
    return _dataArray;
}

@end
