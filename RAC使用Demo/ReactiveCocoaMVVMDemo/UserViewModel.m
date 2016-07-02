//
//  UserViewModel.m
//  ReactiveCocoaMVVMDemo
//
//  Created by jiachenmu on 16/6/30.
//  Copyright © 2016年 ManoBoo. All rights reserved.
//

#import "UserViewModel.h"
#import "User.h"

@implementation UserViewModel

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    if (self) {
        self.userName = user.userName;
        self.userAge = user.userAge;
        self.userAddress = user.userAddress;
    }
    
    return self;
}

//判断用户名、密码是否有效

- (BOOL)isUserNameValid {
    return [self.userName containsString:@"boo"];
}

- (BOOL)isPasswordValid {
    return [self.password containsString:@"666"];
}

- (BOOL)isCanLogin {
    return self.isUserNameValid && self.isPasswordValid;
}

- (RACSignal *)isCanLoginSignal {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.isUserNameValid && self.isPasswordValid) {
            [subscriber sendNext:@(true)];
        }
        [subscriber sendNext:@(false)];
        return nil;
    }];
    
    return signal;
}

@end
