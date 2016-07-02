//
//  Calculator.h
//  HEHEHE
//
//  Created by jiachenmu on 16/6/29.
//  Copyright © 2016年 JiaChenMu. All rights reserved.
//  链式编程Demo

// 通用Block



#import <Foundation/Foundation.h>

@class Calculator;
typedef Calculator *(^CalculatorBlock)(double num);

@interface Calculator : NSObject

+ (instancetype)opeartionNum:(double)num;

@property (assign, nonatomic) double opeartionNum;

//加--减--乘--除

@property (copy, nonatomic) CalculatorBlock add;
@property (copy, nonatomic) CalculatorBlock reduce;
@property (copy, nonatomic) CalculatorBlock multiply;
@property (copy, nonatomic) CalculatorBlock divide;

@end
