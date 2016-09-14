//
//  DNAddressBookHandle.m
//  DNAddressBook
//
//  Created by mainone on 16/9/14.
//  Copyright © 2016年 wjn. All rights reserved.
//

#import "DNAddressBookHandle.h"

@implementation DNAddressBookHandle

+ (void)getAddressBookDataSource:(DNPersonModelBlock)personModel authorizationFailure:(AuthorizationFailure)failure {
    
    if(IOS9_LATER) {
        [self getDataSourceFrom_IOS9_Later:personModel authorizationFailure:failure];
    } else {
        [self getDataSourceFrom_IOS9_Ago:personModel authorizationFailure:failure];
    }
}

#pragma mark - IOS9之前获取通讯录的方法
+ (void)getDataSourceFrom_IOS9_Ago:(DNPersonModelBlock)personModel authorizationFailure:(AuthorizationFailure)failure {
    // 1.获取授权状态
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    // 2.如果没有授权,先执行授权失败的block后return
    if (status != kABAuthorizationStatusAuthorized) { // 已经授权
        failure ? failure() : nil;
        return;
    }
    // 3.创建通信录对象
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    // 4.从通信录对象中,将所有的联系人拷贝出来
    CFArrayRef allPeopleArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 5.遍历每个联系人的信息,并装入模型
    for(id personInfo in (__bridge NSArray *)allPeopleArray) {
        DNPersonModel *model = [DNPersonModel new];
        // 5.1获取到联系人
        ABRecordRef person = (__bridge ABRecordRef)(personInfo);
        // 5.2获取姓名
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *name = [NSString stringWithFormat:@"%@%@%@",lastName?lastName:@"",middleName?middleName:@"",firstName?firstName:@""];
        model.name = name.length > 0 ? name : @"无名氏" ;
        // 5.3获取头像数据
        NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        model.headerImage = [UIImage imageWithData:imageData];
        // 5.4获取每个人所有的电话号码
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneCount = ABMultiValueGetCount(phones);
        for (CFIndex i = 0; i < phoneCount; i++) {
            NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);           //号码
            NSString *mobile = [self removeSpecialSubString:phoneValue];
            [model.mobile addObject: mobile ? mobile : @"空号"];
        }
        // 5.5获取每个人的邮箱地址
        ABMultiValueRef emails= ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex j=0; j<ABMultiValueGetCount(emails); j++) {
            NSString *emailStr = (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(emails, j));
            [model.emailAddresses addObject:emailStr ? emailStr : @"无"];
        }
        // 5.6获取联系人所在公司组织
        NSString*organization=(__bridge NSString*)(ABRecordCopyValue(person, kABPersonOrganizationProperty));
        model.organization = organization ? organization : @"无";
        // 5.7获取联系人所在部门
        NSString*department=(__bridge NSString*)(ABRecordCopyValue(person, kABPersonDepartmentProperty));
        model.department = department ? department : @"无";
        // 5.8获取联系人所担任职务
         NSString*job=(__bridge NSString*)(ABRecordCopyValue(person, kABPersonJobTitleProperty));
        model.job = job ? job : @"无";
        // 5.9获取联系人所有地址
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        for (CFIndex j = 0; j < ABMultiValueGetCount(address); j++) {
            //地址类型()
            NSString * type = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(address, j));
            NSDictionary * temDic = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(address, j));
            // 详细地址建模
            DNAddressModel *addressModel = [[DNAddressModel alloc] init];
            addressModel.type    = type;
            addressModel.country = [temDic valueForKey:(NSString*)kABPersonAddressCountryKey];
            addressModel.state   = [temDic valueForKey:(NSString*)kABPersonAddressStateKey];
            addressModel.city    = [temDic valueForKey:(NSString*)kABPersonAddressCityKey];
            addressModel.street  = [temDic valueForKey:(NSString*)kABPersonAddressStreetKey];
            addressModel.zip     = [temDic valueForKey:(NSString*)kABPersonAddressZIPKey];
            model.address = addressModel;
        }
        
        // 5.5将联系人模型回调出去
        personModel(model);
        CFRelease(phones);
    }
    // 释放不再使用的对象
    CFRelease(allPeopleArray);
    CFRelease(addressBook);
}

#pragma mark - IOS9之后获取通讯录的方法
+ (void)getDataSourceFrom_IOS9_Later:(DNPersonModelBlock)personModel authorizationFailure:(AuthorizationFailure)failure {
#ifdef __IPHONE_9_0
    // 1.获取授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    // 2.如果没有授权,先执行授权失败的block后return
    if (status != CNAuthorizationStatusAuthorized) {
        failure ? failure() : nil;
        return;
    }
    // 3.获取联系人
    // 3.1.创建联系人仓库
    CNContactStore *store = [[CNContactStore alloc] init];
    // 3.2.创建联系人的请求对象
    // keys决定能获取联系人哪些信息,例:姓名,电话,头像等
    NSArray *fetchKeys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey, CNContactOrganizationNameKey, CNContactEmailAddressesKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPostalAddressesKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    
    // 3.3.请求联系人
    NSError *error = nil;
    [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
        // 姓名
        NSString *lastName = contact.familyName;
        NSString *middleName = contact.middleName;
        NSString *firstName = contact.givenName;
        // 创建联系人模型
        DNPersonModel *model = [DNPersonModel new];
        NSString *name = [NSString stringWithFormat:@"%@%@%@",lastName?lastName:@"",middleName?middleName:@"",firstName?firstName:@""];
        model.name = name.length > 0 ? name : @"无名氏" ;
        
        // 联系人头像
        model.headerImage = [UIImage imageWithData:contact.thumbnailImageData];
        // 获取一个人的所有电话号码
        NSArray *phones = contact.phoneNumbers;
        for (CNLabeledValue *labelValue in phones) {
            CNPhoneNumber *phoneNumber = labelValue.value;
            NSString *mobile = [self removeSpecialSubString:phoneNumber.stringValue];
            [model.mobile addObject: mobile ? mobile : @"空号"];
        }
        //获取每个人的邮箱地址
        NSArray *emails = contact.emailAddresses;
        for (CNLabeledValue *labelValue in emails) {
            NSString *emailStr = labelValue.value;
            [model.emailAddresses addObject:emails ? emailStr : @"无"];
            
        }
        //获取联系人所在公司组织
        NSString *organization = contact.organizationName;
        model.organization = organization ? organization : @"无";
        //获取联系人所在部门
        NSString *department = contact.departmentName;
        model.department = department ? department : @"无";
        //获取联系人所担任职务
        NSString *job = contact.jobTitle;
        model.job = job;
        //获取联系人所有地址
        NSArray *addressArr = contact.postalAddresses;
        for (CNLabeledValue *labelValue in addressArr) {
            CNPostalAddress *addr = labelValue.value;
            DNAddressModel *addressModel = [[DNAddressModel alloc] init];
            addressModel.type    = labelValue.label;
            addressModel.country = addr.country;
            addressModel.state   = addr.state;
            addressModel.city    = addr.city;
            addressModel.street  = addr.street;
            addressModel.zip     = addr.postalCode;
            model.address = addressModel;
        }
        //将联系人模型回调出去
        personModel(model);
    }];
#endif
}

//过滤指定字符串(可自定义添加自己过滤的字符串)
+ (NSString *)removeSpecialSubString: (NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

@end
