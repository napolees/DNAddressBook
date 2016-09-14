//
//  DNAddressBookHandle.h
//  DNAddressBook
//
//  Created by mainone on 16/9/14.
//  Copyright © 2016年 wjn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __IPHONE_9_0
#import <Contacts/Contacts.h>
#endif
#import <AddressBook/AddressBook.h>
#import "DNPersonModel.h"

#define IOS9_LATER ([[UIDevice currentDevice] systemVersion].floatValue > 9.0 ? YES : NO )

typedef void(^DNPersonModelBlock)(DNPersonModel *model);/**<一个联系人的相关信息*/
typedef void(^AuthorizationFailure)(void);              /**<授权失败的Block*/

@interface DNAddressBookHandle : NSObject

/**
 *  返回每一个联系人信息的模型
 *
 *  @param personModel 单个联系人模型
 *  @param failure     授权失败回调
 */
+ (void)getAddressBookDataSource:(DNPersonModelBlock)personModel authorizationFailure:(AuthorizationFailure)failure;

@end
