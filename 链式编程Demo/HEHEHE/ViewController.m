//
//  ViewController.m
//  HEHEHE
//
//  Created by jiachenmu on 16/6/27.
//  Copyright (c) 2016年 JiaChenMu. All rights reserved.
//

#import "ViewController.h"
#import "Calculator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"呵呵呵呵呵");
    
    //开始计算
    Calculator *calu = [Calculator opeartionNum:10.00];
    calu.add(2).reduce(2).multiply(2).divide(0);
    //输出结果
    NSLog(@"result : %f",calu.opeartionNum);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
