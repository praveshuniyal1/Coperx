//
//  SpotgyroVC.m
//  Spotgyro
//
//  Created by BinJin on 12/18/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "SpotgyroVC.h"
#import "SettingVC.h"
#import "AppDelegate.h"
#import "SpotNetworkManger.h"
#import "SpotAnnotation.h"
#import "MKMapView+ZoomLevel.h"
#import "StarSlider.h"
#import "ALAlertBanner.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <PassKit/PassKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HeaderFile.h"
#import "AsyncImageView.h"
#import "SVProgressHUD.h"



#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define ZOOM_VALUE  2

@interface SpotgyroVC () <UIApplicationDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, SpotNetworkMangerDelegate>
{
    CLLocationManager   *locationManager_obj;
    AppDelegate         *appDelegate;
    
    BOOL                isInfoBoxVisible;
    BOOL                isOutAboutOn;
    BOOL                isInOutOn;
    BOOL                isRockOnOn;
    BOOL                isDealOn;
    
    SpotAnnotation      *selectedAnnotation;
    
    UIView              *activeMapPopup;
    
    NSTimer             *updateTimer;
    
    NSArray             *filteredList;
}

@property (weak, nonatomic) IBOutlet MKMapView      *paradise;
@property (weak, nonatomic) IBOutlet UIView         *longDayView;
@property (weak, nonatomic) IBOutlet UIView         *longDayListing;
@property (weak, nonatomic) IBOutlet UITableView    *dealsListingTableView;
@property (weak, nonatomic) IBOutlet UIScrollView   *dealScrollView;
@property (weak, nonatomic) IBOutlet UILabel        *infoBoxPlaceName;
@property (weak, nonatomic) IBOutlet UILabel        *infoBoxClassification;
@property (weak, nonatomic) IBOutlet UIButton       *favoriteButton;
@property (weak, nonatomic) IBOutlet UISearchBar    *searchBarControl;

//DeadInfoView
@property (weak, nonatomic) IBOutlet UILabel        *dealBoxDealDescription;
@property (weak, nonatomic) IBOutlet UILabel        *dealBoxTimeLeft;
@property (weak, nonatomic) IBOutlet UIImageView    *dealViewThermometer;

//InfoCardView
@property (weak, nonatomic) IBOutlet UILabel        *lblInfoCardDistance;
@property (weak, nonatomic) IBOutlet UILabel        *lblInfoCardHours;
@property (weak, nonatomic) IBOutlet UILabel        *lblInfoCardAddress1;
@property (weak, nonatomic) IBOutlet UILabel        *lblInfoCardAddress2;
@property (weak, nonatomic) IBOutlet UIButton       *btnInfoCardPhone;
@property (weak, nonatomic) IBOutlet UILabel        *lblChanedTitle;


- (IBAction)centerMap:(id)sender;
- (IBAction)toggleInOut:(id)sender;
- (IBAction)toggleOutAbout:(id)sender;
- (IBAction)toggleRockOn:(id)sender;
- (IBAction)toggleDeal:(id)sender;

@end

@implementation SpotgyroVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    CHECKDATA=TRUE;
    array_deal=[[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.searchDisplayController setSearchResultsDataSource:self];
    [self.searchDisplayController setSearchResultsDelegate:self];
    
    isInfoBoxVisible                = false;
    isOutAboutOn = isRockOnOn = isInOutOn = isDealOn = YES;
    
    
    
    [self update_lat_long];
    
   
    
    [SpotNetworkManger sharedInstance].delegate = self;
    
    appDelegate                     = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIPanGestureRecognizer *panRec  = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    panRec.delegate                 = self;
    [self.paradise addGestureRecognizer:panRec];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HidePopUp_Function) name:@"HidePopUp" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"NotificationAppear" object:nil];
    
    
}


-(void)update_lat_long
{
    locationManager_obj                 = [[CLLocationManager alloc] init];
    
    [locationManager_obj setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager_obj setDistanceFilter:1];
    
    locationManager_obj.delegate        = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        [locationManager_obj requestAlwaysAuthorization];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
    {
        locationManager_obj.allowsBackgroundLocationUpdates = YES;
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Movie_View.hidden=YES;
    
    timerFlasg=TRUE;
    
    [self startLocationUpdate];
    
}

-(void)pushNotificationReceived:(NSNotification*) notification
{
    IsFromNotification = YES;
    [self HitWebService];
    
}

-(void)HitService_Function
{
    [self HitWebService];
}
- (void)viewDidAppear:(BOOL)animated
{
    // Change the map type if needed
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"mapType"])
    {
        NSInteger selectedMapType = [(NSNumber *)[defaults objectForKey:@"mapType"] integerValue];
        
        switch (selectedMapType) {
            case 0:
                self.paradise.mapType = MKMapTypeStandard;
                break;
            case 1:
                self.paradise.mapType = MKMapTypeHybrid;
                break;
            case 2:
                self.paradise.mapType = MKMapTypeSatellite;
                break;
            default:
                self.paradise.mapType = MKMapTypeStandard;
        }
    }
    
    
    [self HitWebService];
    
    //    [self performSelectorInBackground:@selector(HitService_Function) withObject:nil];
}



-(void)HitWebService
{
    
    NSString * str_InstalationID=[[NSUserDefaults standardUserDefaults]objectForKey:@"installationId"];
    
//    NSLog(@"=========%@",str_InstalationID);
    
    if (isStringEmpty(str_InstalationID))
    {
        str_InstalationID=@"";
    }
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       
                                       @{
                                         @"installationId" : str_InstalationID,
                                         }];
    
    //    [[AppManager sharedManager] showHUD:@"Loading..."];
    [self ShowActivityIndicatorWithTitle:@"Loading..."];
    [[AppManager sharedManager] getDataForUrl:@"http://sgaxis.com/Payments/show_user?"
     
                                   parameters:parameters
     
                                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
     
     {
         
         if ([responseObject count]>0)
         {
             
             [self HideActivityIndicator];
             
             arr_CustumPinsData = [[NSMutableArray alloc]init];
             NSLog(@"data===%@",responseObject);
             arr_CustumPinsData = [responseObject objectForKey:@"users"];
             NSInteger status =[[[arr_CustumPinsData objectAtIndex:0] valueForKey:@"status"] integerValue];
             
             if (status == 1 || status == 0)
             {
                 [[NSUserDefaults standardUserDefaults]setObject:[arr_CustumPinsData valueForKey:@"id"] forKey:@"ids"];
                 [[NSUserDefaults standardUserDefaults]setObject:[arr_CustumPinsData valueForKey:@"Typetriangle"] forKey:@"Typetriangle"]
                 ;
                 NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"Typetriangle"]);
                 
                 if (IsfromTapp == YES)
                 {
                     IsfromTapp = NO;
                 }
                 else
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationfromVC" object:nil];
                 }
             }
             else if (status == 2)
             {
                 [self HideActivityIndicator];
                 alert(@"Alert", @"No business found.");
             }
         }
     }
     
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
     {
         [self HideActivityIndicator];
         
         alert(@"Alert", @"Something went wrong.");
         
     }];
    
    
}

-(void)HidePopUp_Function
{
    [self hideInfoBox];
    [self dismissListView];
    [self hideInfoBox];
}

- (void)hideAllDialog
{
    [self hideInfoBox];
    [self dismissListView];
    [self dismissLongDay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGesture Methods

-(void)didDragMap:(UIGestureRecognizer *)gestureRecognizer
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationfromVC" object:nil];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if(isInfoBoxVisible)
        {
            [CountDowntimer invalidate];
            
            [self hideInfoBox];
        }
        
        [self hideSearchBar];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:self.paradise.centerCoordinate.latitude longitude:self.paradise.centerCoordinate.longitude];
        [[SpotNetworkManger sharedInstance] getVenuesForLocation:newLocation];
    }
}

-(void)hideInfoBox
{
    [CountDowntimer invalidate];
    
    [updateTimer invalidate];
    
    updateTimer = nil;
    
    isInfoBoxVisible = false;
    
    for (SpotAnnotation *ann in [self.paradise selectedAnnotations])
    {
        [self.paradise deselectAnnotation:ann animated:YES];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        activeMapPopup.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished) {
            [activeMapPopup removeFromSuperview];
            activeMapPopup.alpha = 1;
        }
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -

#pragma mark - MapViewDelegate Methods

-(void)zoomToUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.5, 0.5);
    region = [self.paradise regionThatFits:region];
    [self.paradise setRegion:region animated:YES];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //[self zoomToUserLocation:userLocation];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(SpotAnnotation *)annotation
{
    if(![annotation isKindOfClass:[SpotAnnotation class]])
        
        return nil;
    
    
    int val = (int)annotation.classification;
    
  
    str_typeoftriangle=@"black";
    

    
    NSArray *classes = @[@"none", @"pink", @"green", @"blue", @"sgyrdeal",str_typeoftriangle];
    
    NSString *imageName = [NSString stringWithFormat:@"%@%d", classes[val], [annotation getCrowdLevel]];
    
    MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:imageName];
    if(!annotationView)
    {
        annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:imageName];
        annotationView.backgroundColor = [UIColor clearColor];
        annotationView.image = [UIImage imageNamed:imageName];
        annotationView.opaque = NO;
    }
    
    return annotationView;
}

- (void)showInformationDeal
{
    CGFloat pixelsPerDegreeLongitude = self.paradise.frame.size.width / self.paradise.region.span.longitudeDelta;
    CGFloat pixelsPerDegreeLatitude = self.paradise.frame.size.height / self.paradise.region.span.latitudeDelta;
    
    CLLocationDegrees longitudinalShift = 0, latitudinalShift = 0;
    
    if (self.view.frame.size.height == 568)
    {
        longitudinalShift   = -4 / pixelsPerDegreeLongitude;
        latitudinalShift    = 120 / pixelsPerDegreeLatitude;
    }
    if (self.view.frame.size.height == 480)
    {
        longitudinalShift   = -4 / pixelsPerDegreeLongitude;
        latitudinalShift    = 165 / pixelsPerDegreeLatitude;
    }
    if (self.view.frame.size.height == 667)
    {
        longitudinalShift   = -4 / pixelsPerDegreeLongitude;
        latitudinalShift    = 60 / pixelsPerDegreeLatitude;
    }
    if (self.view.frame.size.height == 736)
    {
        longitudinalShift   = -4 / pixelsPerDegreeLongitude;
        latitudinalShift    = 32 / pixelsPerDegreeLatitude;
    }
    
    CLLocationCoordinate2D newCenterCoordinate = {selectedAnnotation.coordinate.latitude + latitudinalShift,
        selectedAnnotation.coordinate.longitude + longitudinalShift};
    
    
    [self.paradise setCenterCoordinate:newCenterCoordinate animated:YES];
    
    
    
    if(selectedAnnotation.classification == SGYSpotDealClassification)
    {
        activeMapPopup = [self mapPopupForInformationDeal:selectedAnnotation];
        
    } else
    {
        activeMapPopup = [self mapPopupForInformationDeal:selectedAnnotation];
    }
    
    CGSize size = activeMapPopup.bounds.size;
    CGSize windowSize = self.view.bounds.size;
    activeMapPopup.frame = CGRectMake(windowSize.width/2.0 - size.width/2.0, 85, size.width, size.height);
    activeMapPopup.alpha = 0;
    
    [self.view addSubview:activeMapPopup];
    [self.view bringSubviewToFront:activeMapPopup];
    
    isInfoBoxVisible = true;
    
    // Animate popup fade-in
    [UIView animateWithDuration:0.15
                          delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ activeMapPopup.alpha = 1; }
                     completion:NULL];
    
    [self.dealScrollView flashScrollIndicators];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    selectedAnnotation = (SpotAnnotation *)view.annotation;
    
    if([view.annotation isKindOfClass:[MKUserLocation class]]) // Blue dot
        return;
    
    if (selectedAnnotation.classification == 0)
        return;
    
    if ([self.paradise zoomLevel] <= 11.0)
    {
        MKCoordinateRegion region;
        region.center = selectedAnnotation.coordinate;
        region.span = MKCoordinateSpanMake(0.01, 0.01);
        region = [self.paradise regionThatFits:region];
        [self.paradise setRegion:region animated:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(showInformationDeal) userInfo:nil repeats:NO];
    }
    else
    {
        [self showInformationDeal];
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (isInfoBoxVisible)
    {
        [self hideInfoBox];
    }
    [CountDowntimer invalidate];
    
}

/// Ensure that when the user scrolls the map no annotation is visible
-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    //    if (isInfoBoxVisible)
    //    {
    //        [self hideInfoBox];
    //    }
    
    [CountDowntimer invalidate];
    
    NSLog(@"%lu", (unsigned long)[self.paradise zoomLevel]);
    
    //    if([self.paradise zoomLevel] <= 8)
    //        [self.paradise setCenterCoordinate:[self.paradise centerCoordinate] zoomLevel:8 animated:NO];
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for(MKAnnotationView *v in views)
    {
        // Skip over the blue dot view
        if ([v.annotation isKindOfClass:[SpotAnnotation class]])
        {
            // If that classification is currently deactivated, hide the annotation
            
            int cc = (int)((SpotAnnotation *)(v.annotation)).classification;
            
            if((cc == 1 && !isInOutOn) || (cc == 2 && !isOutAboutOn) || (cc == 3 && !isRockOnOn)|| (cc == 4 && !isDealOn))
            {
                v.hidden = YES;
                v.enabled = NO;
            }
        }
    }
}

-(UIView *)mapPopupForInformationDeal:(SpotAnnotation *)ann
{
    if (ann.foursquareId.length < 14)
    {
        IsfromTapp = YES;
        [self HitWebService];
        
    }
    
    UIView *popup = [[[NSBundle mainBundle] loadNibNamed:@"PlaceInfoPopupView"
                                                   owner:self
                                                 options:nil]
                     objectAtIndex:0];
    
    // Remove all subviews in scrollview
    for (UIView *view in [[self.dealScrollView subviews] copy]) {
        if(![view isKindOfClass:[UIImageView class]]) // Don't remove scroll indicators
            [view removeFromSuperview];
    }
    
    
    self.infoBoxPlaceName.text = [ann.title uppercaseString];
    self.infoBoxClassification.text = ann.subtitle;
    
    // TODO: Change this so that this only happens when there's a deal (deal != nil)
    if(ann.classification == 4 || ann.classification == 5 )
    {
        UIView *scrollView = [[[NSBundle mainBundle] loadNibNamed:@"DealInfoScroll" owner:self options:nil] objectAtIndex:0];
        
        self.dealScrollView.contentSize = CGSizeMake(300, 410);
        
        [self.dealScrollView addSubview:scrollView];
        
        
        UIView *infoCardView = [[[NSBundle mainBundle] loadNibNamed:@"InfoCardView" owner:self options:nil] objectAtIndex:0];
        
        self.lblInfoCardDistance.text   = ann.distanceMile;
        self.lblInfoCardAddress1.text   = ann.city;
        self.lblInfoCardAddress2.text   = ann.address;
        self.lblChanedTitle.text        = NSLocalizedString(@"HOUR", @"HOUR");
        [self.btnInfoCardPhone setTitle:ann.phone forState:UIControlStateNormal];
        
        NSString *imageName = [NSString stringWithFormat:@"termo%d", [ann getCrowdLevel]];
        self.dealViewThermometer.image = [UIImage imageNamed:imageName];
        
        infoCardView.frame = CGRectMake(0, 228, 300, 187);
        [self.dealScrollView addSubview:infoCardView];
        
        
        
        
        arr_com=[NSMutableArray alloc];
        arr_com=[[NSUserDefaults standardUserDefaults]objectForKey:@"ids"];
        
        
        for (int i=0; i<arr_com.count; i++)
        {
            if ([[arr_com objectAtIndex:i]isEqualToString:ann.foursquareId])
            {
                self.dealBoxDealDescription.text = [[arr_CustumPinsData valueForKey:@"deal"] objectAtIndex:i];
                
                hour=[[NSString stringWithFormat:@"%@",[[arr_CustumPinsData valueForKey:@"hours"] objectAtIndex:i]] intValue];
                Status_Of_Fav=[[NSString stringWithFormat:@"%@",[[arr_CustumPinsData valueForKey:@"status"] objectAtIndex:i]] intValue];
                
                NSLog(@"%ld",(long)Status_Of_Fav);
                minit=[[NSString stringWithFormat:@"%@",[[arr_CustumPinsData valueForKey:@"minutes"] objectAtIndex:i]] intValue];
                
                sec=[[NSString stringWithFormat:@"%@",[[arr_CustumPinsData valueForKey:@"sec"] objectAtIndex:i]] intValue];
                
                Video_url= [NSString stringWithFormat:@"%@",[[arr_CustumPinsData valueForKey:@"video"] objectAtIndex:i]];
                urlTextEscaped = [Video_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                
            }
        }
        
        
        
        if(Status_Of_Fav == 1)
        {
            [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"heart-red"] forState:UIControlStateNormal];
        }
        else
        {
            [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        }
        
        NSLog(@"%@",urlTextEscaped);
        str_Type=[NSString stringWithFormat:@"%@",[urlTextEscaped pathExtension]];
        NSLog(@"%@",str_Type);
        
        if (str_Type.length==0)
        {
            btn_VideoImage.hidden=YES;
        }
        else if ([str_Type isEqualToString:@"mov"] || [str_Type isEqualToString:@"mp4"] || [str_Type isEqualToString:@"m4v"]|| [str_Type isEqualToString:@"3gp"] || [str_Type isEqualToString:@"avi"])
        {
            btn_VideoImage.hidden=NO;
            [btn_VideoImage setTitle:NSLocalizedString(@"Video", @"Video") forState:UIControlStateNormal];
        }
        else
        {
            btn_VideoImage.hidden=NO;
            [btn_VideoImage setTitle:NSLocalizedString(@"Image", @"Image") forState:UIControlStateNormal];
        }
        
        
        CountDowntimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(TimerFired) userInfo:nil repeats:YES];
        
    }
    else
    {
        UIView *scrollView = [[[NSBundle mainBundle] loadNibNamed:@"InfoCardView" owner:self options:nil] objectAtIndex:0];
        
        self.lblInfoCardDistance.text   = ann.distanceMile;
        self.lblInfoCardAddress1.text   = ann.city;
        self.lblInfoCardAddress2.text   = ann.address;
        self.lblChanedTitle.text        = NSLocalizedString(@"CATEGORY", @"CATEGORY");
        
        switch (ann.classification) {
            case 1:
                self.lblInfoCardHours.text = NSLocalizedString(@"In and Out", @"In and Out");
                break;
            case 2:
                self.lblInfoCardHours.text = NSLocalizedString(@"Social", @"Social");
                break;
            case 3:
                self.lblInfoCardHours.text = NSLocalizedString(@"Nightlife", @"Nightlife");
                break;
        }
        
        [self.btnInfoCardPhone setTitle:ann.phone forState:UIControlStateNormal];
        
        self.dealScrollView.contentSize = CGSizeMake(300, 212);
        [self.dealScrollView addSubview:scrollView];
    }
    
    return popup;
}

-(void)TimerFired
{
    
    if(hour>0 || minit >0 || sec>0)
    {
        
        
        if (sec==0)
        {
            
            if (minit==0 && sec==0)
            {
                if (minit==0 && hour==0)
                {
                    sec=60;
                    timerFlasg=FALSE;
                }
                
                if(hour==0 && minit==0 && sec==0)
                {
                    [CountDowntimer invalidate];
                    timerFlasg=FALSE;
                    
                }
            }
            
            if (timerFlasg==TRUE && minit==0 && sec==0)
            {
                hour=hour-1;
                minit=60;
                sec=60;
            }
            else
            {
                sec=60;
            }
            
            minit=minit-1;
            
            
        }
        
        if(sec>0)
        {
            sec=sec-1;
        }
        
        self.dealBoxTimeLeft.text=[NSString stringWithFormat:@"%d : %d : %d",hour,minit,sec];
        
    }
    else
    {
        [CountDowntimer invalidate];
    }
    
    
    //    if (hour!=0 || minit!=0 || sec!=0)
    //    {
    //
    //        if(sec > 0 )
    //    {
    //        sec -- ;
    //        hours = sec / 3600;
    //        minutes = (sec % 3600) / 60;
    //        seconds = (sec %3600) % 60;
    //        self.dealBoxTimeLeft.text=[NSString stringWithFormat:@"%d : %d : %d",hours,minutes,seconds];
    //
    //    }
    //    else
    //    {
    //        sec = 16925;
    //    }
    //    }
    //    else
    //    {
    //        [CountDowntimer invalidate];
    //    }
    
    //    if((minit>0 || sec>=0) && minit>=0)
    //    {
    //        if (minit==59 && sec==59)
    //        {
    //            hour-=1;
    //        }
    //        if(sec==0)
    //        {
    //            minit-=1;
    //            sec=59;
    //        }
    //        if(sec>0)
    //        {
    //            sec-=1;
    //        }
    //
    //        self.dealBoxTimeLeft.text=[NSString stringWithFormat:@"%d : %d : %d",hour,minit,sec];
    //    }
    //    else
    //    {
    //        [CountDowntimer invalidate];
    //    }
    
    
    //    if(minit>0 || sec>=0 || hour>=0)
    //    {
    //        if (minit==0 && sec==0)
    //        {
    //            hour= hour-1;
    //        }
    //        if(sec==0)
    //        {
    //            if (hour==0 && minit==0)
    //            {
    //                minit=60;
    //            }
    //            minit=minit-1;
    //            sec=60;
    //        }
    //        if(sec>0)
    //        {
    //            sec=sec-1;
    //        }
    //
    //        self.dealBoxTimeLeft.text=[NSString stringWithFormat:@"%d : %d : %d",hour,minit,sec];
    //    }
    //    else
    //    {
    //        [CountDowntimer invalidate];
    //    }
}

-(void) setCorrectHeartImageInPopupForSpotFoursquareId:(NSString *)foursquareId
{
    if([[SpotNetworkManger sharedInstance] hasUserFavoritedSpotWithFoursquareId:foursquareId]) {
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"heart-red"] forState:UIControlStateNormal];
    }
    else {
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    }
}

- (IBAction)TappedOnVideoOpen:(id)sender
{
    [self hideInfoBox];
    

    
    if ([str_Type isEqualToString:@"mov"])
    {
        NSLog(@"%@",urlTextEscaped);
        
        MoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlTextEscaped]];;
        
        if (IS_IPHONE_5)
        {
            MoviePlayer.view.frame = CGRectMake(0,64,320,504);
        }
        else if (IS_IPHONE_6)
        {
            MoviePlayer.view.frame = CGRectMake(0,64,375,603);
            
        }
        else if (IS_IPHONE_6_PLUS)
        {
            MoviePlayer.view.frame = CGRectMake(0,64,414,672);
            //
        }
        Movie_View.hidden=NO;
        imageVW_Photo.hidden=YES;
        [Movie_View addSubview:MoviePlayer.view];
        [MoviePlayer play];
        
        //    [MoviePlayer setFullscreen:YES animated:NO];
        //    MoviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete:)name:MPMoviePlayerPlaybackDidFinishNotification                                               object:MoviePlayer];
        
    }
    else
    {
        
        imageVW_Photo.hidden=NO;
        Movie_View.hidden=NO;
        imageVW_Photo.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@",urlTextEscaped]];
    }
    
}
- (IBAction)DoneVideoAction:(id)sender
{
    [MoviePlayer stop];
    [MoviePlayer.view removeFromSuperview];
    Movie_View.hidden=YES;
    imageVW_Photo.hidden=YES;
    self.tabBarController.tabBar.hidden=NO;
    
}


- (IBAction)favoriteButtonTouched:(id)sender
{
    if (Status_Of_Fav == 1)
    {
        InputStatus_of_FAv = 0;
    }
    else
    {
        InputStatus_of_FAv = 1;
        
    }

    
    
    NSString * str_InstalationID=[[NSUserDefaults standardUserDefaults]objectForKey:@"installationId"];
    NSString * str_statusFAV = [NSString stringWithFormat:@"%ld",(long)InputStatus_of_FAv];
    if (isStringEmpty(str_InstalationID))
    {
        str_InstalationID=@"";
    }
    if (isStringEmpty(str_statusFAV))
    {
        str_statusFAV=@"";
    }
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       
                                       @{
                                         
                                         @"id" : selectedAnnotation.foursquareId,
                                         @"status" : str_statusFAV,
                                         @"installationId" : str_InstalationID
                                         
                                         }];
    
    //    [[AppManager sharedManager] showHUD:@"Loading..."];
    
    [[AppManager sharedManager] getDataForUrl:@"http://sgaxis.com/Payments/update_noti?"
     
                                   parameters:parameters
     
                                      success:^(AFHTTPRequestOperation *operation, NSMutableArray *responseObject)
     
     {
         // Get response from server
         
         if ([responseObject count]>0)
         {
             
             //             [[AppManager sharedManager]hideHUD];
             if ([[[responseObject objectAtIndex:0] valueForKey:@"status"]  isEqual: @"1"])
             {
                 [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"heart-red"] forState:UIControlStateNormal];
                 Status_Of_Fav = 1;
             }
             else
             {
                 [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
                 Status_Of_Fav = 0;
                 
             }
             
         }
     }
     
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
     {
                alert(@"Alert", @"Something went wrong.");
         
     }];
    
  
}

#pragma mark -

#pragma mark - CLLocationManagerDelegate Methods

//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//
//    NSLog(@"locationManager");
//    NSLog(@"%@ %@",newLocation,oldLocation);
//    latitude_obj = locationManager.location.coordinate.latitude;
//    longitude_obj = locationManager.location.coordinate.longitude;
//
//
//    [[SpotNetworkManger sharedInstance] updateCurrentLocation:newLocation];
//    [self hideInfoBox];
//
//    MKCoordinateRegion region;
//    region.center = newLocation.coordinate;
//    region.span = MKCoordinateSpanMake(0.5, 0.5);
//    region = [self.paradise regionThatFits:region];
//    [self.paradise setRegion:region animated:YES];
//  //  [locationManager stopUpdatingLocation];
//
//    [self Location_Send_to_server_Webservice];
//
//
//    [[SpotNetworkManger sharedInstance] getVenuesForLocation:newLocation];
//}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Assigning the last object as the current location of the device
    CLLocation *currentLocation = [locations lastObject];
    
    latitude_obj = locationManager_obj.location.coordinate.latitude;
    longitude_obj = locationManager_obj.location.coordinate.longitude;
    
    
    [[SpotNetworkManger sharedInstance] updateCurrentLocation:currentLocation];
    [self hideInfoBox];
    
    MKCoordinateRegion region;
    region.center = currentLocation.coordinate;
    region.span = MKCoordinateSpanMake(0.5, 0.5);
    region = [self.paradise regionThatFits:region];
    [self.paradise setRegion:region animated:YES];
    [locationManager_obj stopUpdatingLocation];
    
    [self Location_Send_to_server_Webservice];
    
    
    [[SpotNetworkManger sharedInstance] getVenuesForLocation:currentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    UIAlertView *objAlertView = [[UIAlertView alloc]initWithTitle:@"failed" message:@"failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//    [objAlertView show];
    [locationManager_obj stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [manager startUpdatingLocation];
    }
}

-(void)Location_Send_to_server_Webservice
{
    
    
    NSString * token=[[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
    
    NSLog(@"=====================%@",token);
    
    if (isStringEmpty(token))
    {
        token=@"";
    }
    
    NSNumber *myDoubleNumber1 = [NSNumber numberWithDouble:latitude_obj];
    
     NSNumber *myDoubleNumber2 = [NSNumber numberWithDouble:longitude_obj];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       //device_tokan=169&lat=123&lng=456
                                       @{
                                         @"device_tokan" : token,
                                         @"lat":[myDoubleNumber1 stringValue],
                                         @"lng":[myDoubleNumber2 stringValue]
                                         }];
    
    //    [[AppManager sharedManager] showHUD:@"Loading..."];
    [self ShowActivityIndicatorWithTitle:@"Loading..."];
    [[AppManager sharedManager] getDataForUrl:@"http://sgaxis.com/Payments/update_lat_lng?"
     
                                   parameters:parameters
     
                                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
     
     {
         
   
         [self HideActivityIndicator];
         NSArray *array =(NSArray *) responseObject;
         
         
         if ([[[array objectAtIndex:0]valueForKey:@"status"]integerValue]==1)
         {
             NSLog(@"successfully send latitude and longitude");
         }
         else
         {
             NSLog(@"Not successfully send latitude and longitude");
             
         }
         
         
     }
     
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
     {
         [self HideActivityIndicator];
        
         
         alert(@"Alert", @"Something went wrong.");
         
     }];
    
}

#pragma mark -

#pragma mark - UIAction Methods

- (IBAction)centerMap:(id)sender
{
    [self update_lat_long];
}

- (IBAction)toggleInOut:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if((isInOutOn = !isInOutOn))
    {
        [button setImage:[UIImage imageNamed:@"InAndOut.png"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Showing Quick", @"Showing Quick Snack Spots")
                       subtitle:nil show:YES];
        [self showAnnotationsOfClassification:1];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"InAndOutOff.png"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Hiding Quick", @"Hiding Quick Snack Spots") subtitle:nil show:NO];
        [self hideAnnotationsOfClassification:1];
    }
}
- (IBAction)toggleOutAbout:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if((isOutAboutOn = !isOutAboutOn))
    {
        [button setImage:[UIImage imageNamed:@"OutAndAbout.png"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Showing Social", @"Showing Social and Adventure Spots") subtitle:nil show:YES];
        [self showAnnotationsOfClassification:2];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"OutAndAboutOff.png"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Hiding Social", @"Hiding Social and Adventure spots") subtitle:nil show:NO];
        [self hideAnnotationsOfClassification:2];
    }
}

- (IBAction)toggleRockOn:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if((isRockOnOn = !isRockOnOn))
    {
        [button setImage:[UIImage imageNamed:@"RockOn"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Showing Rockin", @"Showing Rockin' Spots") subtitle:nil show:YES];
        [self showAnnotationsOfClassification:3];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"RockOnOff"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Hiding Rockin", @"Hiding Rockin' Spots") subtitle:nil show:NO];
        
        [self hideAnnotationsOfClassification:3];
    }
}

- (IBAction)toggleDeal:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if((isDealOn = !isDealOn))
    {
        [button setImage:[UIImage imageNamed:@"realDeals"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Showing Instant", @"Showing Instant Deals") subtitle:nil show:YES];
        [self showAnnotationsOfClassification:4];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"realDealsOff"] forState:UIControlStateNormal];
        [self showFilterMessage:NSLocalizedString(@"Hiding Instant", @"Hiding Instant Deals") subtitle:nil show:NO];
        [self hideAnnotationsOfClassification:4];
        
    }
}

- (void)showFilterMessage:(NSString *)msg subtitle:(NSString *)sub show:(BOOL)sh
{
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:appDelegate.window style:sh ? ALAlertBannerStyleSuccess : ALAlertBannerStyleFailure position:ALAlertBannerPositionUnderNavBar title:msg subtitle:sh ? sub : nil];
    //[ALAlertBanner hideAllAlertBanners];
    banner.showAnimationDuration = 0.15f;
    banner.hideAnimationDuration = 0.1f;
    if (sh) {
        banner.secondsToShow = 3.8;
    }
    else {
        banner.secondsToShow = 1;
    }
    
    [banner show];
}

- (void)showAnnotationsOfClassification:(int)classification
{
    //    for(SpotAnnotation *a in [self.paradise annotationsInMapRect:self.paradise.visibleMapRect])
    //    {
    for(SpotAnnotation *a in [self.paradise annotations])
    {
        if ([a isKindOfClass:[MKUserLocation class]])
            continue; // ignore the blue dot annotation
        if(a.classification == classification)
        {
            [self.paradise viewForAnnotation:a].alpha = 0;
            [self.paradise viewForAnnotation:a].hidden = NO;
            [UIView animateWithDuration:0.41f animations:^{
                [self.paradise viewForAnnotation:a].alpha = 1.0f;
            } completion:^(BOOL finished) {
                if(finished) {
                    for(SpotAnnotation *ann in [self.paradise annotations])
                    {
                        if ([ann isKindOfClass:[MKUserLocation class]])
                            continue; // ignore the blue dot view
                        
                        if(ann.classification == classification)
                        {
                            [self.paradise viewForAnnotation:ann].hidden = NO;
                            [self.paradise viewForAnnotation:ann].enabled = YES;
                            [self.paradise viewForAnnotation:ann].alpha = 1;
                        }
                    }
                }
            }];
        }
    }
}

- (void) hideAnnotationsOfClassification:(int)classification
{
    //for(SpotAnnotation *a in [self.paradise annotationsInMapRect:self.paradise.visibleMapRect])
    for(SpotAnnotation *a in [self.paradise annotations])
    {
        if ([a isKindOfClass:[MKUserLocation class]])
            continue; // ignore the blue dot view
        
        if(a.classification == classification)
        {
            [UIView animateWithDuration:0.19f animations:^{
                [self.paradise viewForAnnotation:a].alpha = 0.0f;
            } completion:^(BOOL done){
                if(done)
                {
                    for(SpotAnnotation *ann in [self.paradise annotations])
                    {
                        if ([ann isKindOfClass:[MKUserLocation class]])
                            continue; // ignore the blue dot view
                        
                        if(ann.classification == classification)
                        {
                            [self.paradise viewForAnnotation:ann].hidden = YES;
                            [self.paradise viewForAnnotation:ann].enabled = NO;
                        }
                    }
                }
            }];
        }
    }
}

- (IBAction)longDayPressed:(id)sender
{
    [self hideInfoBox];
    
    [[NSBundle mainBundle] loadNibNamed:@"LongDay" owner:self options:nil];
    [self.view addSubview:self.longDayView];
    
    self.longDayView.frame =self.view.frame;
    
    [UIView animateWithDuration:0.16f animations:^{
        self.longDayView.alpha = 1.0;
    }];
}

- (IBAction)btnFav_Action:(id)sender
{
    [[SpotNetworkManger sharedInstance] getFavoriteSpot];
}

- (IBAction)btnSearch_Action:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBarControl.alpha = 1.0;
        self.searchBarControl.frame = CGRectMake(0, 76, self.searchBarControl.frame.size.width, self.searchBarControl.frame.size.height);
    }];
    
}

- (void)hideSearchBar
{
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBarControl.alpha = 0.0;
        self.searchBarControl.frame = CGRectMake(0, 32, self.searchBarControl.frame.size.width, self.searchBarControl.frame.size.height);
    }];
}

#pragma mark - Tracking Methods

- (void)startLocationUpdate
{
    // Create the location manager if this object does not
    // already have one.
    if ([locationManager_obj respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) {
            // We never ask for authorization. Let's request it.
            [locationManager_obj requestAlwaysAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                   [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            locationManager_obj.delegate        = self;
            
            // We have authorization. Let's update location.
            [locationManager_obj startUpdatingLocation];
        } else {
            // If we are here we have no pormissions.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"athorization", @"No athorization")
                                                                message:NSLocalizedString(@"enable acces", @"Please, enable access to your location")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"cancelAction", @"Cancel")
                                                      otherButtonTitles:NSLocalizedString(@"Open Setting", @"Open Settings"), nil];
            [alertView show];
        }
    } else {
        // This is iOS 7 case.
        [locationManager_obj startUpdatingLocation];
    }
}

#pragma mark - SpotNetworkMangerDelegate Methods

- (void)spotManage:(SpotNetworkManger*)manager didAddSpots:(NSArray *)spots
{
    
    [self.paradise addAnnotations:spots];
}

- (void)spotManage:(SpotNetworkManger*)manager didRemoveSpots:(NSArray *)spots
{
    [self.paradise removeAnnotations:spots];
}

- (void)spotManage:(SpotNetworkManger*)manager didGetFavorite:(SpotAnnotation*)anno
{
    if (anno == nil)
        return;
    
    [self zoomToSpot:anno];
    
    [self.paradise selectAnnotation:anno animated:YES];
}

#pragma mark -

#pragma mark - LongDay View

- (IBAction)longDayCancelled:(id)sender
{
    [self dismissLongDay];
}

-(void)dismissLongDay
{
    // Animate the subview that dissapears
    [UIView animateWithDuration:0.16f animations:^{
        self.longDayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.longDayView removeFromSuperview];
    }];
}

- (IBAction)imThirstyPressed:(id)sender
{
    [self appearListView];
    [self dismissLongDay];
}

- (IBAction)imHungryPressed:(id)sender
{
    [self appearListView];
    [self dismissLongDay];
}

- (IBAction)dismissListViewPressed:(id)sender
{
    [self dismissListView];
}

- (void)appearListView
{
    // Slide in the listing
    [[NSBundle mainBundle] loadNibNamed:@"LongDayListing" owner:self options:nil];
    self.longDayListing.alpha = 0.0;
    
    [self.view addSubview:self.longDayListing];
    
    [_dealsListingTableView reloadData];
    
    // Add the nearby spots (spots with deals have a higher priority)
    
    self.longDayListing.frame = self.view.frame;
    
    [UIView animateWithDuration:0.20f animations:^{
        self.longDayListing.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissListView
{
    // Fade out the listing
    [UIView animateWithDuration:0.16f animations:^{
        self.longDayListing.transform = CGAffineTransformMakeTranslation(0.0, 30.0);
        self.longDayListing.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.longDayListing removeFromSuperview];
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:nil];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSArray *spots = [[SpotNetworkManger sharedInstance] getSpots];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    filteredList = [spots filteredArrayUsingPredicate:resultPredicate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return filteredList.count;
    }
    
    return [[SpotNetworkManger sharedInstance] getSpots].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        SpotAnnotation *spot = filteredList[indexPath.row];
        cell.textLabel.text = spot.title;
        cell.detailTextLabel.text = spot.subtitle;
    }
    else
    {
        NSArray *spots = [[SpotNetworkManger sharedInstance] getSpots];
        SpotAnnotation *spot = spots[indexPath.row];
        cell.textLabel.text = spot.title;
        cell.detailTextLabel.text = spot.subtitle;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [self.searchDisplayController setActive:NO];
        [self hideSearchBar];
        
        SpotAnnotation *spot = filteredList[indexPath.row];
        
        [self dismissListView];
        
        [self autoSelectAnnoView:spot];
    }
    else
    {
        NSArray *spots = [[SpotNetworkManger sharedInstance] getSpots];
        
        SpotAnnotation *spot = spots[indexPath.row];
        
        [self dismissListView];
        
        [self autoSelectAnnoView:spot];
    }
}

- (void)autoSelectAnnoView:(SpotAnnotation*)spot
{
    //[self zoomToSpot:spot];
    [self.paradise selectAnnotation:spot animated:YES];
}

-(void)zoomToSpot:(SpotAnnotation *)spot
{
    MKCoordinateRegion region;
    region.center = spot.coordinate;
    region.span = MKCoordinateSpanMake(0.001, 0.001);
    region = [self.paradise regionThatFits:region];
    [self.paradise setRegion:region animated:YES];
}

#pragma mark - DeadInfoView Methods

-(void)displayDealPopupForAnnotation:(SpotAnnotation *)ann
{
    // Load the deal popup from the xib
    activeMapPopup = [[[NSBundle mainBundle] loadNibNamed:@"PlaceInfoPopupView" owner:self options:nil] objectAtIndex:0];
    
    // Smoothly animate fade-in
    activeMapPopup.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        activeMapPopup.alpha = 1;
    }];
    
    // Create the inner scrollview
    UIView *scrollView = [[[NSBundle mainBundle] loadNibNamed:@"DealInfoScroll" owner:self options:nil] objectAtIndex:0];
    
    self.dealScrollView.contentSize = CGSizeMake(300, 270);
    [self.dealScrollView addSubview:scrollView];
    
    // Populate the fields from database
    
    // Info box title and label
    self.infoBoxPlaceName.text = ann.title;
    self.infoBoxClassification.text = ann.subtitle;
    
    // Follow the link into the real-time deal object contained in the annotation
    if(ann.deal)
    {
        self.dealBoxTimeLeft.text = [ann.deal getRemainingTimeString];
        self.dealBoxDealDescription.text = ann.deal.dealText;
        
        // Update the remaining time by creating a timer
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self selector:@selector(onTimerForDealUpdate:) userInfo:ann.deal repeats:YES];
        
    }}

-(void)onTimerForDealUpdate:(NSTimer *)timer
{
    SpotDeal *deal = [timer userInfo];
    self.dealBoxTimeLeft.text = [deal getRemainingTimeString];
    
    if ([self.dealBoxTimeLeft.text isEqualToString:@"Expired :("])
    {
        [updateTimer invalidate];
        updateTimer = nil;
        
        [[SpotNetworkManger sharedInstance] getVenuesForLocation:locationManager_obj.location];
    }
}

- (IBAction)directionsButtonTouched:(id)sender
{
    [self giveDrivingDirectionsToSelectedAnnotation];
}

- (IBAction)saveAndUseTouched:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://sgaxis.herokuapp.com/v1/passes/deal"];
    NSData *passData = [NSData dataWithContentsOfURL:url];
    NSError* error = nil;
    PKPass *newPass = [[PKPass alloc] initWithData:passData
                                             error:&error];
    PKAddPassesViewController *addController = [[PKAddPassesViewController alloc] initWithPass:newPass];
    
    if (addController)
    {
        [self presentViewController:addController
                           animated:YES
                         completion:nil];
    }
}

-(void)giveDrivingDirectionsToSelectedAnnotation
{
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: selectedAnnotation.coordinate addressDictionary:nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = selectedAnnotation.title;
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}

#pragma mark -

#pragma mark - InfoCardView Methods

- (IBAction)phoneButtonTouched:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:self.btnInfoCardPhone.titleLabel.text
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancelAction", @"Cancel")
                                          otherButtonTitles:NSLocalizedString(@"callAction", @"Call"), nil];
    
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self makeCall:self.btnInfoCardPhone.titleLabel.text];
    }
}

- (void)makeCall:(NSString *)number
{
    NSString *phoneNumDecimalsOnly = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumDecimalsOnly]];
    [[UIApplication sharedApplication] openURL:telURL];
}
-(void)ShowActivityIndicatorWithTitle:(NSString *)Title{
    [SVProgressHUD showWithStatus:Title maskType:SVProgressHUDMaskTypeGradient];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}
-(void)HideActivityIndicator
{
    [SVProgressHUD dismiss];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark -

@end
