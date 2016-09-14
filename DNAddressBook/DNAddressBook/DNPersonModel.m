//
//  DNPersonModel.m
//  DNAddressBook
//
//  Created by mainone on 16/9/14.
//  Copyright © 2016年 wjn. All rights reserved.
//

#import "DNPersonModel.h"

@implementation DNPersonModel

- (NSMutableArray *)mobile {
    if(!_mobile) {
        _mobile = [NSMutableArray array];
    }
    return _mobile;
}

- (NSMutableArray *)emailAddresses {
    if (!_emailAddresses) {
        _emailAddresses = [NSMutableArray array];
    }
    return _emailAddresses;
}

@end


@implementation DNAddressModel

@end

