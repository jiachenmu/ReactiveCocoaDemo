//
//  ViewController.h
//  ReactiveCocoaMVVMDemo
//
//  Created by jiachenmu on 16/6/30.
//  Copyright © 2016年 ManoBoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserViewModel;

@interface ViewController : UIViewController

- (instancetype)initWithViewModel:(UserViewModel *)userViewModel;

@end

