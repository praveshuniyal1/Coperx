//
//  HeaderFile.h
//  Deal App
//
//  Created by Shiju Varghese on 09/10/14.
//  Copyright (c) 2014 Shiju Varghese. All rights reserved.
//

#ifndef Deal_App_HeaderFile_h
#define Deal_App_HeaderFile_h

#import "AppDelegate.h"

//dev414.trigma.us/lynkd/Webs/mobileregister/?first_name=mohan&last_name=xyz&email=pankaj.kumar@trigma.in&username=sk&password=123456&cpassword=123456&country=india&state=UK&city=dun&account_type=business&zipcode=123

#define BASE_URL        @"http://dev414.trigma.us/lynkd/Webs/"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x69c2eb);

#define kAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define kFileManager               [NSFileManager defaultManager]
#define kTitle                     @"TITLE:"

#define userInfoKey @"userInfoKey"

#define GCDBackgroundThread dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define GCDMainThread dispatch_get_main_queue()

#endif
