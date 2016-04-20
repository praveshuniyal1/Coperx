//
//  SpotgyroVC.h
//  Spotgyro
//
//  Created by BinJin on 12/18/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppManager.h"

@interface SpotgyroVC : UIViewController

{
    NSMutableArray *arr_dummy;
    int count;
    
    NSInteger *lati;
    NSInteger *lng;
    NSMutableArray * arr_Venue_ID;
    BOOL isOrangeApears;
    BOOL CHECKDATA;
    NSMutableArray *arr_parse_ID;
    NSMutableArray *array_deal;
    NSMutableArray *arr_hours;
    NSMutableArray *arr_mint;
    NSMutableArray *arr_sec;
    NSTimer * CountDowntimer;
    int minit,sec,hour;
    int hours,minutes,seconds;
    BOOL timerFlasg;
    NSDictionary *json;
    NSMutableArray *json_FAV;
    MPMoviePlayerController *MoviePlayer;
    IBOutlet UIView *Movie_View;
    NSMutableArray *arr_com;
    NSString *Video_url;
    NSMutableArray * arr_VideoURL;
    NSString *str_Type;
    NSMutableArray * arr_TypeofTriangle;
    NSMutableDictionary * Dic_TypesandIds;
    NSMutableArray * arr_selectedtypes;
    
    IBOutlet UIButton *btn_VideoImage;
    IBOutlet UIImageView *imageVW_Photo;
    NSString * ForSqureID;
    NSString * str_typeoftriangle;
    NSString* urlTextEscaped;
    NSInteger Status_Of_Fav;
    NSInteger InputStatus_of_FAv;

    NSMutableArray * arr_fav;
    NSMutableArray * arr_CustumPinsData;
    BOOL IsFromNotification;
    BOOL IsfromTapp;
    double latitude_obj ,longitude_obj;
}
- (void)hideAllDialog;

@end

