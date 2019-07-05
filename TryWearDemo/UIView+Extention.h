//
//  UIView+Extention.h
//  TryWearDemo
//
//  Created by mac on 2019/5/8.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extention)
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;
@end

NS_ASSUME_NONNULL_END
