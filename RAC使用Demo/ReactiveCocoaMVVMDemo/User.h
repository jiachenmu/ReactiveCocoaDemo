//
//  User.h
//  ReactiveCocoaMVVMDemo
//
//  Created by jiachenmu on 16/6/30.
//  Copyright © 2016年 ManoBoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Programmer <NSObject>

- (void)whoAmI;

@end

@interface User : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *userAddress;
@property (assign, nonatomic) float userAge;

@end
