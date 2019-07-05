//
//  EditCell.m
//  TryWearDemo
//
//  Created by mac on 2019/5/8.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "EditCell.h"
#import "Masonry/Masonry.h"

//十六进制颜色
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation EditCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.title = [[UILabel alloc]init];
        self.title.textColor = UIColorFromRGB(0x323232);
        self.title.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.title];
        
        self.imageview = [[UIImageView alloc]init];
        [self.contentView addSubview:self.imageview];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageview.mas_bottom).offset(5);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.contentView);
    }];
}

@end
