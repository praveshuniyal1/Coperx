//
//  AppManager.m
//  Deal App
//
//  Created by Shiju Varghese on 09/10/14.
//  Copyright (c) 2014 Shiju Varghese. All rights reserved.
//

#import "AppManager.h"
#import "HeaderFile.h"
#import "Reachability.h"
#import "MPNotificationView.h"
//#import "JSON.h"
//#import "User.h"

@implementation AppManager

static AppManager *_sharedAppManager = nil;
int offset = 15;

+(AppManager *) sharedManager{

    @synchronized([AppManager class]){
    
        if (!_sharedAppManager)
            _sharedAppManager = [[AppManager alloc] init];
        
        return _sharedAppManager;
    }
    return nil;
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}
#pragma mark Get Document Directory
NSString* documentDirectory()
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

/*
#pragma mark Create Document Directory
void createDirectory(NSString *dirName)
{
    NSError *error;
    NSString *dataPath = documentDirectoryPath(dirName);
    
    NSLog(@"Directory Path %@", dataPath);
    
    if (![kFileManager fileExistsAtPath:dataPath])
        [kFileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
}

#pragma mark Add Document Directory Path
NSString* documentDirectoryPath(NSString* fileName)
{
    return [documentDirectory() stringByAppendingPathComponent:fileName];
}


#pragma mark Get Document Directory
NSString* documentDirectory()
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

#pragma mark- read File
NSString *readFileTo(NSString *folderName, NSString *fileName)
{
    NSString *appFile = documentDirectoryPath([folderName stringByAppendingPathComponent:fileName]);
    
    NSFileManager *fileManager=kFileManager;
    
    if ([fileManager fileExistsAtPath:appFile])
    {
        NSError *error= NULL;
        
        id resultData=[NSString stringWithContentsOfFile:appFile encoding:NSUTF8StringEncoding error:&error];
        
        if (error == NULL)
        {
            return resultData;
            
        }
    }
    return NULL;
}

#pragma mark- get Current Date And Time
NSString *getCurrentDateAndTime(){
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    return dateString;
}

#pragma mark- get All Files On Sorted Form & Modified Date
NSArray *getAllSortedFiles(){
    
    NSString* documentsPath = documentDirectoryPath(@"PROFILE_PHOTOS");
    
    NSError* error = nil;
    
    // Get All text files
    NSArray* filesArray = [kFileManager contentsOfDirectoryAtPath:documentsPath error:&error];
    if(error != nil) {
        NSLog(@"Error in reading files: %@", [error localizedDescription]);
        return nil;
    }
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    for(NSString* file in filesArray) {
        NSString* filePath = [documentsPath stringByAppendingPathComponent:file];
        NSDictionary* properties = [kFileManager
                                    attributesOfItemAtPath:filePath
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
        }
    }
    
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];
    
    return sortedFiles;
}

#pragma mark- File Deleted
BOOL isFileDeleted(NSString *contentOfFile){
    
    NSLog(@"contentOfFile : %@", contentOfFile);
    NSString *titleOfFile = filePath(contentOfFile);
    NSError *error;
    BOOL fileDeleted = [kFileManager removeItemAtPath:[documentDirectoryPath(@"PROFILE_PHOTOS") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", titleOfFile]] error:&error];
    
    if (fileDeleted != YES || error != nil)
    {
        // Deal with the error...
        NSLog(@"Error %@", [error description]);
    }
    
    return fileDeleted;
}

#pragma mark- File Path
NSString *filePath(NSString *filename){
    
    NSArray* allLines = [filename componentsSeparatedByString:@"\n"];
    NSString* title = @"";
    for (NSString* _line in allLines) {
        if ([_line isKindOfClass:[NSString class]]) {
            if ([_line rangeOfString:kTitle].length) {
                title = [_line stringByReplacingOccurrencesOfString:kTitle withString:@""];
            }
        }
    }
    
    // Check white space
    NSCharacterSet *whitespace  = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString     = [title stringByTrimmingCharactersInSet:whitespace];
    
    return trimmedString;
}
 
 - (NSString*)encyptString:(NSString*)str
 {
 NSMutableString *encrptedString = [[NSMutableString alloc] init];
 for (int i = 0; i < str.length; i++) {
 unichar character = [str characterAtIndex:i];
 character += offset;
 [encrptedString appendFormat:@"%C", character];
 }
 return encrptedString;
 }
 
 - (NSString*)decryptString:(NSString*)str
 {
 NSMutableString *decrptedString = [[NSMutableString alloc] init];
 for (int i = 0; i < str.length; i++) {
 unichar character = [str characterAtIndex:i];
 character -= offset;
 [decrptedString appendFormat:@"%C", character];
 }
 return decrptedString;
 }
 */

+(NSString*)getCurrectValue:(NSString*)content
{
    
    if((content==[NSNull class])||([content isEqual:@"null"])||([content isEqual:@"(null)"])||([content isEqual:@"<null>"])||([content isEqual:@"nil"])||([content isEqual:@""])||([content isEqual:@"<nil>"])||(content.length==0))
        
        // if ((content == (id)[NSNull null]) || (content.length == 0) || ([content isEqualToString:@""])|| ([content isEqualToString:@"(null)"]) )
    {
        return @"";
        
    }
    else
    {
        return content;
    }
    
}

#pragma mark alert
void alert(NSString *alert, NSString *message)
{
    
    UIAlertView *objAlertView = [[UIAlertView alloc]initWithTitle:alert message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [objAlertView show];
}

#pragma mark- is String Empty
BOOL isStringEmpty(NSString *string) {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}
BOOL validateEmailWithString(NSString *emailText){

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if (![emailTest evaluateWithObject:emailText]) {
        
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        NSLog(@"emailValid : %s",[emailTest evaluateWithObject:emailText]?"YES":"NO");
        return [emailTest evaluateWithObject:emailText];
    }
    
    NSLog(@"emailValid : %s",[emailTest evaluateWithObject:emailText]?"YES":"NO");
    return [emailTest evaluateWithObject:emailText];
}


#pragma mark- hide HUD
-(void)hideHUD
{
    [self.HUD hide:YES];
}

#pragma mark- show HUD
-(void)showHUD:(NSString *)str
{
    [self showHUDInView:self.navCon.view :str];
}

#pragma mark- show HUD InView
-(void)showHUDInView:(UIView *)view :(NSString *)message
{
    if(self.HUD) [self.HUD removeFromSuperview];
    
    self.HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
  //  self.HUD.labelText = @"Loading...";
    self.HUD.labelText = message;

}

#pragma mark- Web service Common method

-(void)getDataForUrl:(NSString *)URLString
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}

#pragma mark- removeAllKey
- (void) removeAllKey:(NSString*)key{

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark- selectedClass and Key's
- (void) selectedClass:(BOOL)value andKey:(NSString*)key{

    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark- Get Age Of User with NSDate
// http://iosdevblog.com/2012/03/22/calculate-age-from-an-nsdate-in-objective-c/
- (NSString *)age:(NSDate *)dateOfBirth {
    
    NSInteger years;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    
    NSLog(@"years:%d", (int)years);
    NSString *strYears = [NSString stringWithFormat:@"%d", (int) years];
    
    return strYears;
}

#pragma mark- logOut
- (void) logOut
{

    [self.navCon popToRootViewControllerAnimated:YES];
}

+ (NSString *)dataFilePath:(BOOL)forSave {
    return [[NSBundle mainBundle] pathForResource:@"config" ofType:@"xml"];
}

-(BOOL)CheckReachability
{
    BOOL returnYesNo;
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable)
    {
        returnYesNo = YES;
    }
    else
    {
        returnYesNo = NO;
        [MPNotificationView notifyWithText:@"No Network Connection"
                                    detail:@"Connect to a Wi-Fi network or a cellular data."
                                     image:nil
                                  duration:2.0
                                      type:@"Custom"
                             andTouchBlock:^(MPNotificationView *notificationView)
         {
             NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
         }];
        
    }
    return returnYesNo;
}

@end
