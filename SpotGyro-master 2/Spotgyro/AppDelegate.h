//
//  AppDelegate.h
//  Spotgyro
//
//  Created by BinJin on 12/18/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessageView.h"


@class SpotgyroVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow          *window;

@property (strong, nonatomic) SpotgyroVC        *rootController;

@end

