//
//  ViewController.m
//  TryWearDemo
//
//  Created by mac on 2019/5/8.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "ViewController.h"
#import "TryWearViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)tryWearAction:(id)sender {
    TryWearViewController *tryWearVC = [[TryWearViewController alloc]init];
    tryWearVC.type = @"5";
    tryWearVC.tryImage = [UIImage imageNamed:@"商品2"];
    [self presentViewController:tryWearVC animated:YES completion:nil];
}

@end
