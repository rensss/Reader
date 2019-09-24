//
//  RKSelectImageViewController.m
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKSelectImageViewController.h"
#import "RKSelectImageCollectionViewCell.h"

/*
 260/369 = 0.7
 1125/2001 = 0.56
 */

#define kPadding 10
#define kWidth ((self.view.width - 4*kPadding - 1)/3.0f)
#define kHeight (kWidth*8.0f/5.0f)

@interface RKSelectImageViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/
@property (nonatomic, strong) NSIndexPath *selectIndex; /**< 选中的索引*/

@end

@implementation RKSelectImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == RKSelectImageTypeBgImage) {
        self.navigationItem.title = @"阅读背景";
    } else {
        self.navigationItem.title = @"书籍封面";
    }
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveClick)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - 点击事件
- (void)saveClick {
    if (self.type == RKSelectImageTypeBgImage && self.selectIndex && self.callBack) {
        [RKUserConfig sharedInstance].bgImageName = self.dataArray[self.selectIndex.item];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            [RKUserConfig sharedInstance].fontColor = @"ffffff";
        }
        
        self.callBack();
    }
    
    if (self.type == RKSelectImageTypeCoverImage) {
        NSMutableArray *bookList = [[RKFileManager shareInstance] getHomeList];
        
        for (RKBook *subBook in bookList) {
            if ([subBook.bookID isEqualToString:self.book.bookID]) {
                subBook.coverImage = self.dataArray[self.selectIndex.item];
            }
        }
        [[RKFileManager shareInstance] saveBookList:bookList];
        [RKFileManager shareInstance].isNeedRefresh = YES;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 代理
#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    self.selectIndex = indexPath;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RKSelectImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RKSelectImageCollectionViewCell class]) forIndexPath:indexPath];
    
    cell.imageName = self.dataArray[indexPath.item];
    
    return cell;
}

#pragma mark - getting
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        flowLayout.minimumLineSpacing = kPadding;
        flowLayout.minimumInteritemSpacing = kPadding;
        flowLayout.itemSize = CGSizeMake(kWidth, kHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - TOP_MARGIN) collectionViewLayout:flowLayout];
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(kPadding, kPadding, kSafeAreaBottom, kPadding);
        _collectionView.contentInset = edgeInsets;
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[RKSelectImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([RKSelectImageCollectionViewCell class])];
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        if (self.type == RKSelectImageTypeBgImage) {
            for (int i = 0; i < 10; i++) {
                [_dataArray addObject:[NSString stringWithFormat:@"reader_bg_%d",i]];
            }
        } else {
            for (int i = 1; i < 12; i++) {
                [_dataArray addObject:[NSString stringWithFormat:@"cover%d",i]];
            }
        }
    }
    return _dataArray;
}

@end
