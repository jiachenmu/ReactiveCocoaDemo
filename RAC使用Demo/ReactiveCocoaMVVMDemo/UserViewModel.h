//
//  UserViewModel.h
//  ReactiveCocoaMVVMDemo
//
//  Created by jiachenmu on 16/6/30.
//  Copyright © 2016年 ManoBoo. All rights reserved.
//  ViewModel层

#import <Foundation/Foundation.h>

@class User;

@interface UserViewModel : NSObject

- (instancetype)initWithUser:(User *)user;

@property (strong, nonatomic, readwrite) NSString *userName;
@property (assign, nonatomic, readonly, getter=isUserNameValid) BOOL userNameValid;

@property (strong, nonatomic, readwrite) NSString *password;
@property (assign, nonatomic, readonly, getter=isPasswordValid) BOOL passwordVaild;

@property (strong, nonatomic) NSString *userAddress;
@property (assign, nonatomic) float userAge;

- (BOOL)isCanLogin;

- (RACSignal *)isCanLoginSignal;

@end
