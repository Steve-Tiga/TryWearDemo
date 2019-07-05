//
//  EditViewController.m
//  TryWearDemo
//
//  Created by mac on 2019/5/8.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "EditViewController.h"
#import "EditCell.h"
#import "GPUImage.h"
#import "Masonry/Masonry.h"

#define kFilterName @[@"原图", @"阳光", @"幽暗", @"灰白", @"怀旧"]
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

//十六进制颜色
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EditViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UIImageView *imageview;
@property (nonatomic,strong)EditCell *selectCell;

@property (nonatomic,strong)UICollectionView *filterCollectionView;
@property (nonatomic, strong) GPUImagePicture *stillImageSource;
@property (nonatomic, strong) GPUImageHazeFilter *hazeFilterBrighter; // 滤镜 —— 阳光
@property (nonatomic, strong) GPUImageHazeFilter *hazeFilterDarker; // 滤镜 —— 幽暗
@property (nonatomic, strong) GPUImageGrayscaleFilter *grayFilter; // 滤镜 —— 灰白
@property (nonatomic, strong) GPUImageSepiaFilter *sepiaFilter; // 滤镜 —— 怀旧
@property (nonatomic, strong) NSMutableArray *filteredArray; // 滤镜处理的数组

@end

@implementation EditViewController

- (NSMutableArray *)filteredArray {
    if (!_filteredArray) {
        _filteredArray = [[NSMutableArray alloc] init];
    }
    
    return _filteredArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initFilters];
}
- (void)initFilters {
    self.hazeFilterBrighter = [[GPUImageHazeFilter alloc] init];
    self.hazeFilterBrighter.distance = -0.3;
    self.hazeFilterDarker = [[GPUImageHazeFilter alloc] init];
    self.hazeFilterDarker.distance = 0.3;
    self.grayFilter = [[GPUImageGrayscaleFilter alloc] init];
    self.sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:self.image];
    
    //添加上滤镜
    [pic addTarget:self.hazeFilterBrighter];
    [pic addTarget:self.hazeFilterDarker];
    [pic addTarget:self.grayFilter];
    [pic addTarget:self.sepiaFilter];
    
    //开始渲染
    [pic processImage];
    
    [self.hazeFilterBrighter useNextFrameForImageCapture];
    [self.hazeFilterDarker useNextFrameForImageCapture];
    [self.grayFilter useNextFrameForImageCapture];
    [self.sepiaFilter useNextFrameForImageCapture];
    
    [self.filteredArray addObject:self.image];
    [self.filteredArray addObject:[self.hazeFilterBrighter imageFromCurrentFramebuffer]];
    [self.filteredArray addObject:[self.hazeFilterDarker imageFromCurrentFramebuffer]];
    [self.filteredArray addObject:[self.grayFilter imageFromCurrentFramebuffer]];
    [self.filteredArray addObject:[self.sepiaFilter imageFromCurrentFramebuffer]];
    [self createUI];
}

- (void)createUI{
    
    self.imageview = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageview];
    self.imageview.image = self.image;
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenW, 100));
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [layout setItemSize:CGSizeMake(100, 100)];
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 10;
    self.filterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 100) collectionViewLayout:layout];
    self.filterCollectionView.backgroundColor = [UIColor whiteColor];
    self.filterCollectionView.scrollEnabled = YES;
    self.filterCollectionView.showsVerticalScrollIndicator = NO;
    self.filterCollectionView.showsHorizontalScrollIndicator = NO;
    [self.filterCollectionView registerClass:[EditCell class] forCellWithReuseIdentifier:@"FilterCollectionViewCell"];
    [backView addSubview:self.filterCollectionView];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
    headView.backgroundColor = [UIColorFromRGB(0xffcac4) colorWithAlphaComponent:0.85];
    [self.view addSubview:headView];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = @"拍摄照片";
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = UIColorFromRGB(0x323232);
    [headView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerX.equalTo(headView);
        make.top.equalTo(headView.mas_top).offset(33);
    }];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"返回" forState:UIControlStateNormal];
    [cancel setTitleColor:UIColorFromRGB(0x323232) forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancel addTarget:self action:@selector(backHome) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:cancel];
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.equalTo(headView.mas_left).offset(20);
        make.centerY.equalTo(label.mas_centerY);
    }];
    
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    [save setTitle:@"分享" forState:UIControlStateNormal];
    [save setTitleColor:UIColorFromRGB(0x323232) forState:UIControlStateNormal];
    save.titleLabel.font = [UIFont systemFontOfSize:15];
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:save];
    [save mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.right.equalTo(headView.mas_right).offset(-20);
        make.centerY.equalTo(label.mas_centerY);
    }];
}
- (void)backHome{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //    return self.filteredArray.count;
    return 5;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"FilterCollectionViewCell";
    EditCell *cell = (EditCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.imageview.image = [UIImage imageNamed:@"img"];
            break;
        case 1:
            cell.imageview.image = [UIImage imageNamed:@"img"];
            break;
        case 2:
            cell.imageview.image = [UIImage imageNamed:@"img"];
            break;
        case 3:
            cell.imageview.image = [UIImage imageNamed:@"img"];
            break;
        case 4:
            cell.imageview.image = [UIImage imageNamed:@"img"];
            break;
            
        default:
            break;
    }
    
    cell.title.text = kFilterName[indexPath.row];
    //    FilterValueModel *model = self.filterValueArray[self.imageIndex];
    //    if (model.filterIndex == indexPath.row) {
    //        cell.filterImageView.layer.borderColor = kRGBColor(235, 117, 117).CGColor;
    //        cell.filterImageView.layer.borderWidth = 2.0;
    //    }else {
    //        cell.filterImageView.layer.borderWidth = 0;
    //    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    //褐色滤镜
    //    GPUImageSepiaFilter *disFilter = [[GPUImageSepiaFilter alloc] init];
    //
    //    //设置要渲染的区域
    //    [disFilter forceProcessingAtSize:self.image.size];
    //    [disFilter useNextFrameForImageCapture];
    //
    //    //获取数据源
    //    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:self.image];
    //
    //    //添加上滤镜
    //    [stillImageSource addTarget:disFilter];
    //    //开始渲染
    //    [stillImageSource processImage];
    //    //获取渲染后的图片
    //    UIImage *newImage = [disFilter imageFromCurrentFramebuffer];
    
    
    
    EditCell *cell = (EditCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.imageview.layer.borderColor = UIColorFromRGB(0xff2160).CGColor;
    cell.imageview.layer.borderWidth = 2.0;
    
    UIImage *newImage = self.filteredArray[indexPath.item];
    //加载出来
    self.imageview.image = newImage;
    
}
- (void)save{
    [self saveImageToPhotoAlbum:self.imageview.image];
    NSArray *arr = @[self.imageview.image];
//    [Share shareWithImage:arr Url:nil Title:nil Content:nil];
}
#pragma mark - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}
#pragma mark - 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    //    [JProgressHUD showPopViewAtView:self.firstView WithImage:[UIImage imageNamed:@"bj"] WithTitle:msg WithViewH:(ScreenH - 64) WithY:0.4];
}

@end
