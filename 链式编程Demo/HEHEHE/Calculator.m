//
//  Calculator.m
//  HEHEHE
//
//  Created by jiachenmu on 16/6/29.
//  Copyright © 2016年 JiaChenMu. All rights reserved.
//

#import "Calculator.h"

@implementation Calculator

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self buildBlock];
    }
    return self;
}

+ (instancetype)opeartionNum:(double)num {
    Calculator *calu = [[Calculator alloc] init];
    calu.opeartionNum = num;
    
    return calu;
}

- (void)buildBlock {
    __weak typeof(self) weakSelf = self;
    _add = ^Calculator *(double num){
        weakSelf.opeartionNum += num;
        return weakSelf;
    };
    
    _reduce = ^Calculator *(double num){
        weakSelf.opeartionNum -= num;
        return weakSelf;
    };
    
    _multiply = ^Calculator *(double num){
        weakSelf.opeartionNum *= num;
        return weakSelf;
    };
    
    _divide = ^Calculator *(double num){
        //除数为0 不作处理
        weakSelf.opeartionNum = _opeartionNum / (num == 0 ? 1 : num);
        return weakSelf;
    };
}


@end
