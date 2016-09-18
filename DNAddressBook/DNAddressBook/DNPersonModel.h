//
//  DNPersonModel.h
//  DNAddressBook
//
//  Created by mainone on 16/9/14.
//  Copyright © 2016年 wjn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DNAddressModel;

@interface DNPersonModel : NSObject

@property (nonatomic, copy)   NSString       *name;           /**<联系人姓名*/
@property (nonatomic, copy)   NSMutableArray *mobile;         /**<联系人电话号码,可能有多个号*/
@property (nonatomic, copy)   UIImage        *headerImage;    /**<联系人头像*/
@property (nonatomic, copy)   NSMutableArray *emailAddresses; /**<联系人电子邮箱,可能有多个*/
@property (nonatomic, copy)   NSString       *organization;   /**<联系人的公司组织*/
@property (nonatomic, copy)   NSString       *department;     /**<联系人的部门*/
@property (nonatomic, copy)   NSString       *job;            /**<联系人的职位*/
@property (nonatomic, strong) DNAddressModel *address;        /**<联系人地址,包括地址类型和详细地址*/

@end



@interface DNAddressModel : NSObject

@property (nonatomic, copy) NSString *type;     /**<电话类型*/
@property (nonatomic, copy) NSString *country;  /**<国家*/
@property (nonatomic, copy) NSString *state;    /**<省*/
@property (nonatomic, copy) NSString *city;     /**<市*/
@property (nonatomic, copy) NSString *street;   /**<街道*/
@property (nonatomic, copy) NSString *zip;      /**<邮政编码*/

@end





