//
//  AppDelegate.m
//  Spotgyro
//
//  Created by BinJin on 12/18/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "AppDelegate.h"
#import "SpotgyroVC.h"
#import "ICETutorialController.h"
#import "ICETutorialPage.h"
#import "Foursquare2.h"
//#import "Fabric/Fabric.h"
//#import "Crashlytics/Crashlytics.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SpotgyroVC.h"

@interface AppDelegate ()
{
    ICETutorialController   *tutorialController;    
}

@end

@implementation AppDelegate


#pragma mark - Parse Framework

#pragma mark Facebook post-login callbacks

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL success = NO;
    
    success =  [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication
                            withSession:[PFFacebookUtils session]];
    
    if (success)
        return success;
    
    success = [Foursquare2 handleURL:url];
    
    return success;
}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [Fabric with:@[CrashlyticsKit]];
    
    [Parse setApplicationId:@"W9VIr2Not15KcOMOetAv9cZm0J3AGk9zpWXS49EJ"
                  clientKey:@"57W975Kq2G25yYZmJfSs29oPkkNzsJguC1aGkzDx"];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        // Register for Push Notifications before iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                               UIRemoteNotificationTypeAlert |
                                                                               UIRemoteNotificationTypeSound)];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self setupTutorial];
    }
    [PFUser becomeInBackground:@"1"];
    [PFTwitterUtils initializeWithConsumerKey:@"rSXBFAiC9ViJkVHLxdg" consumerSecret:@"irHe0awOxtyfVFlX2zKYwnT82PI7uXC2Op5CJh4"];
    
    return YES;
}


- (void)setupTutorial
{
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithSubTitle:NSLocalizedString(@"welcomeNote", @"Welcome to Spotgyro")
                                                            description:NSLocalizedString(@"simplifed", @"We have simplifed the way you look\nfor food and drinks")
                                                            pictureName:@"tutorial_background_00@2x.jpg"];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithSubTitle:NSLocalizedString(@"meter", @"Crowd Meter")
                                                            description:NSLocalizedString(@"Find whats", @"Find what's popular at\nthis very moment")
                                                            pictureName:@"tutorial_background_02@2x.jpg"];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithSubTitle:NSLocalizedString(@"Spot Filters", @"Spot Filters and Personalized Deals")
                                                            description:NSLocalizedString(@"Focus on", @"Focus on the spots and deals that\nyou actually care about")
                                                            pictureName:@"tutorial_background_04@2x.jpg"];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithSubTitle:NSLocalizedString(@"Spotgyro Radar", @"Spotgyro Radar")
                                                            description:NSLocalizedString(@"Keeps an", @"Keeps an eye for instant deals nearby,\nso you're always in the loop")
                                                            pictureName:@"tutorial_background_03@2x.jpg"];

    ICETutorialLabelStyle *subStyle = [[ICETutorialLabelStyle alloc] init];
    [subStyle setFont:TUTORIAL_SUB_TITLE_FONT];
    [subStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [subStyle setLinesNumber:TUTORIAL_SUB_TITLE_LINES_NUMBER];
    [subStyle setOffset:TUTORIAL_SUB_TITLE_OFFSET];
    
    ICETutorialLabelStyle *descStyle = [[ICETutorialLabelStyle alloc] init];
    [descStyle setFont:TUTORIAL_DESC_FONT];
    [descStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [descStyle setLinesNumber:TUTORIAL_DESC_LINES_NUMBER];
 
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4];
    tutorialController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController"
                                                                 bundle:nil
                                                               andPages:tutorialLayers];

    self.rootController =(SpotgyroVC*)self.window.rootViewController;
    
    __weak __block typeof(self) weakSelf = self;
    [tutorialController setButton1Block:^(UIButton *button){
        weakSelf.window.rootViewController = weakSelf.rootController;
        [weakSelf.window makeKeyAndVisible];
        
        
    }];
    
    [tutorialController setCommonPageSubTitleStyle:subStyle];
    [tutorialController setCommonPageDescriptionStyle:descStyle];
    
    [tutorialController startScrolling];
    
    self.window.rootViewController = tutorialController;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [[NSUserDefaults standardUserDefaults]setObject:[currentInstallation valueForKey:@"installationId"] forKey:@"installationId"];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addObject:[NSString stringWithFormat:@"Spotgyro%@", [PFInstallation currentInstallation].installationId] forKey:@"channels"];
        [currentInstallation saveInBackground];
    }];
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceToken=[NSString stringWithFormat:@"%@",token];
    [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:@"token"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"Device Token %@",token);

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    
    if(application.applicationState == UIApplicationStateInactive)
    {
        

        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAppear" object:nil];

        
    }
    else if (application.applicationState == UIApplicationStateBackground)
    {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAppear" object:nil];

        
        
    }
    else
    {


        [TSMessage showNotificationInViewController:nil
                                              title:NSLocalizedString([[userInfo objectForKey:@"data"] objectForKey:@"name"], nil)
                                           subtitle:NSLocalizedString([[userInfo objectForKey:@"aps"] objectForKey:@"alert"], nil)
                                              image:nil
                                               type:TSMessageNotificationTypeMessage
                                           duration:4.0f
                                           callback:^{}
                                        buttonTitle:nil
                                     buttonCallback:^
         {
             // here perform action on tap of Chat now button
             
             
         }
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
        
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAppear" object:nil];

//        completionHandler(UIBackgroundFetchResultNewData);
        
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self.rootController hideAllDialog];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HidePopUp" object:nil];
        
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
