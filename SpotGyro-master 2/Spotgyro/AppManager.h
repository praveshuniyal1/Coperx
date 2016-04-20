//
//  AppManager.h
//  Deal App
//
//  Created by Shiju Varghese on 09/10/14.
//  Copyright (c) 2014 Shiju Varghese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFile.h"
#import "MBProgressHUD.h"

//#import "User.h"

@interface AppManager : NSObject

//enum deviceCheck
//{
//    iPhone_4,
//    iPhone_5,
//    iPhone_6,
//    iPhone_6Plus
//};

//@property (assign,nonatomic)enum deviceCheck device;
//
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic,retain)  UINavigationController* navCon;
//@property (nonatomic,retain)  User *user;

+ (AppManager *) sharedManager;
+(NSString*)getCurrectValue:(NSString*)content;

//- (void) showHUDInView:(UIView*)view;
-(void)showHUDInView:(UIView *)view :(NSString*)message;

- (void) logOut;
-(BOOL)CheckReachability;


- (void) hideHUD;
- (void) showHUD :(NSString*)str;
-(void) showPickerView;

- (void) getDataForUrl:(NSString *)URLString
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/*
 - (void) selectedClass:(BOOL)value andKey:(NSString*)key;
 - (void) removeAllKey:(NSString*)key;
 
 - (NSString*)encyptString:(NSString*)str;
 - (NSString*)decryptString:(NSString*)str;
 
 - (NSString *)age:(NSDate *)dateOfBirth;
 
-(NSDictionary*)imageData1:(NSData*)imageData1 imageData2:(NSData*)imageData2 imageData3:(NSData*)imageData3 imageData4:(NSData*)imageData4 user:(User*)userResult;

-(id) getLoginResultsForUrl:(NSString *)email password:(NSString*) pwd;
-(id) getProfileSignUpResultsForUrl:(NSString*) urlString dictProfile:(NSDictionary*) dict;
-(id) getPersnalitySignUpResultsdependable:(NSString*)dependable friendship:(NSString*)friendship space:(NSString*)space user_id:(NSString*)user_id;

//+ (BOOL) validateEmailWithString:(NSString*)emailText;

- (id) getProfileSignUpResultsName:(NSString*)fname lastName:(NSString*)lname emailText:(NSString*)email phoneText:(NSString*)phone password:(NSString*)pwd;

- (id) getContactSignUpResultsUserID:(NSString*)userId gender:(NSString*)gender dob:(NSString*)ddob address:(NSString*)address city:(NSString*)city state:(NSString*)state country:(NSString*)country;

- (id) getGeneralSignUpResultsUserID:(NSString*)userId rel_Status:(NSString*)rel_Status children:(NSString*)children smoke:(NSString*)smoke drink:(NSString*)drink veg:(NSString*)veg;

- (id) getHobbyignUpResultsMoviesID:(NSString*)movieId music:(NSString*)musicId sport:(NSString*)sportId tv:(NSString*)tvId reading:(NSString*)readingId eatingOut:(NSString*)eatingOutId goingout:(NSString*)goingoutId userId:(NSString*)userId q1:(NSString*)strHobbies;

- (id) getOccupationSignUpResultsUserID:(NSString*)userId occupId:(NSString*)occupId did:(NSString*)did eid:(NSString*)eid income:(NSString*)income;
*/
    
BOOL isStringEmpty(NSString *string);
/*
 // Check TextField is empty or not
 if(isStringEmpty(self.textFieldFirstName.text)) {
 
 [self.textFieldFirstName becomeFirstResponder];
 alert(@"Alert", @"Please enter first name");
 return;
 }
 
 */
BOOL validateEmailWithString(NSString *emailText);
/*
 if (!validateEmailWithString(self.textFieldEmail.text)) {
 
 [self.textFieldEmail becomeFirstResponder];
 alert(@"Alert", @"Please enter valid email");
 return;
 }
 */

void alert(NSString *alert, NSString *message);

NSString* checkCurrentTime(double seconds);
NSString* documentDirectory();
NSString* readFileTo(NSString *folderName, NSString *fileName);
NSString* filePath(NSString *filename);
NSString* getCurrentDateAndTime();
NSString* documentDirectoryPath(NSString* fileName);

NSArray *getAllSortedFiles();

void createDirectory(NSString *dirName);
BOOL isFileDeleted(NSString *contentOfFile);

@end
