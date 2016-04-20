//
//  SpotNetworkManger.m
//  Spotgyro
//
//  Created by BinJin on 12/24/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "SpotNetworkManger.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "SpotAnnotation.h"
#import "FSVenue.h"
#import "AppManager.h"

@interface SpotNetworkManger()
{
    NSArray             *inAndOutCategoriesArray;
    NSArray             *outAndAboutCategoriesArray;
    NSArray             *rockOnCategoriesArray;
    NSMutableArray * arr_custumDATA;
    NSDictionary * json;
    
    NSMutableDictionary *foursquareSpotAnnotations;
    NSMutableSet        *thisUsersFavoriteSpots;
    
    CLLocationCoordinate2D currentLocation;
    BOOL IsFromNotification;
    CLLocation * LocationforCustum;
}

@end

@implementation SpotNetworkManger

+ (instancetype)sharedInstance
{
    static SpotNetworkManger *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    arr_custumDATA = [[NSMutableArray alloc]init];
//    [self GetCustumDATA];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"NotificationfromVC" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"NotificationfromVC" object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(GetCustumDATA) userInfo:nil repeats:YES];

    [self performSelectorInBackground:@selector(GetCustumDATA) withObject:nil];

    foursquareSpotAnnotations   = [NSMutableDictionary dictionary];
    thisUsersFavoriteSpots      = [NSMutableSet set];
    
    [Foursquare2 setupFoursquareWithClientId:FourSquareClientID
                                      secret:FourSquareSecretKey
                                 callbackURL:@"spotgyro://foursquare"];
    
    return self;
}
-(void)pushNotificationReceived:(NSNotification*) notification
{
    IsFromNotification = YES;
    [self GetCustumDATA];
}

- (void)getVenuesForLocation:(CLLocation *)location
{
    currentLocation = location.coordinate;
    LocationforCustum = location;
    
    [self getInAndOutForLocation:location];
    [self getOutAndAboutForLocation:location];
    [self getRockOnForLocation:location];
    [self getDealsForLocation:location];
    
    if((arr_custumDATA==[NSNull class])||([arr_custumDATA isEqual:@"null"])||([arr_custumDATA isEqual:@"(null)"])||([arr_custumDATA isEqual:@"<null>"])||([arr_custumDATA isEqual:@"nil"])||([arr_custumDATA isEqual:@""])||([arr_custumDATA isEqual:@"<nil>"])||(arr_custumDATA.count==0))
    {
        NSLog(@"No data Found");
    }
    else
    {
        [self getInAndOutCustumData:location];
    }
}

-(void)GetCustumDATA
{
    NSString * str_InstalationID=[[NSUserDefaults standardUserDefaults]objectForKey:@"installationId"];
    
    if (isStringEmpty(str_InstalationID))
    {
        str_InstalationID=@"";
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       
                                       @{
                                         
                                         @"installationId" : str_InstalationID,
                                         
                                         }];
    
//    [[AppManager sharedManager] showHUD:@"Loading..."];
    
    [[AppManager sharedManager] getDataForUrl:@"http://sgaxis.com/Payments/show_user?"
     
                                   parameters:parameters
     
                                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
     
     {
         // Get response from server
         
         if ([responseObject count]>0)
         {
//             [[AppManager sharedManager]hideHUD];
             [self getInAndOutCustumData:LocationforCustum];

             arr_custumDATA = [[NSMutableArray alloc]init];
             [arr_custumDATA addObject:[responseObject valueForKey:@"users"]];
         //    NSLog(@"DATACUTUM >>>> %@",arr_custumDATA);
             
//             [[NSUserDefaults standardUserDefaults]setObject:[arr_custumDATA valueForKey:@"id"] forKey:@"ids"];
//             
//             [[NSUserDefaults standardUserDefaults]setObject:[arr_custumDATA valueForKey:@"Typetriangle"] forKey:@"Typetriangle"]
//             ;
//             NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"Typetriangle"]);

         }
     }
     
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
     {
         [[AppManager sharedManager]hideHUD];
         NSLog(@"manu fjdcj");
         alert(@"Alert", @"Something went wrong.");
         
     }];
    
}

- (void)getDealsForLocation:(CLLocation *)location
{
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:[location coordinate].latitude
                                                      longitude:[location coordinate].longitude];
    
    PFQuery *permanentSpotsQuery = [PFQuery queryWithClassName:@"Spot"];
    [permanentSpotsQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:kNearByRadius];
    permanentSpotsQuery.limit = kPermanentSpotsQueryLimit;
    
    [permanentSpotsQuery includeKey:@"deal"];
    [permanentSpotsQuery findObjectsInBackgroundWithTarget:self
                                                  selector:sel_registerName("permanentSpotsFound:error:")];
}

-(void)permanentSpotsFound:(NSArray *)spots error:(NSError *)error
{
    if(!error)
    {
        NSMutableArray *annotationsToAdd = [NSMutableArray array];
        NSMutableArray *annotationsToRemove = [NSMutableArray array];
        
        for(PFObject *retrievedSpot in spots)
        {
            SpotAnnotation *spot = [SpotAnnotation sgySpotAnnotationFromParseData:retrievedSpot CurrLocation:currentLocation];
            if ([spot.deal isActive] == NO)
            {
                continue;
            }
            
            SpotAnnotation *existingAnnotation = [foursquareSpotAnnotations objectForKey:spot.foursquareId];
            
            [foursquareSpotAnnotations setObject:spot forKey:spot.foursquareId];
            
            if(existingAnnotation)
            {
                NSInteger hereNow = existingAnnotation.hereNow;
                [annotationsToRemove addObject:existingAnnotation];
                spot.hereNow = hereNow;
                [annotationsToAdd addObject:spot];
            }
            else
            {
                [annotationsToAdd addObject:spot];
            }
        }
        
        if ([annotationsToRemove count] > 0)
        {
            [_delegate spotManage:self didRemoveSpots:annotationsToRemove];
        }
        
        if([annotationsToAdd count] > 0)
        {
            [_delegate spotManage:self didAddSpots:annotationsToAdd];
            
            if (annotationsToAdd.count == 1)
            {
                SpotAnnotation *spot = annotationsToAdd[0];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      spot.deal.dealText,@"alert",
                                      @"Increment", @"badge",
                                      @"default", @"sound",
                                      nil];
                
                [PFPush sendPushDataToChannelInBackground:[PFInstallation currentInstallation].channels[0] withData:data];
            }
            else
            {
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Multiple deals nearby!",@"alert",
                                      @"Increment", @"badge",
                                      @"default", @"sound",
                                      nil];
                
                [PFPush sendPushDataToChannelInBackground:[PFInstallation currentInstallation].channels[0] withData:data];
            }
        }
    }
}
- (void)getInAndOutCustumData:(CLLocation *)location
{
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(kMinimumFoursquareRequestRadius)
                                categoryId:kDealBlackOnCategoriesString
                                  callback:^(BOOL success, id result){
                                      if (success) {
//                                          NSDictionary *dic = result;
//                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc]init];
                                          inAndOutCategoriesArray = [converter convertToObjects:[arr_custumDATA objectAtIndex:0]];
                                          
                                          [self addSport:inAndOutCategoriesArray];
                                      }
                                  }];
}

- (void)getInAndOutForLocation:(CLLocation *)location
{
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(kMinimumFoursquareRequestRadius)
                                categoryId:kInAndOutCategoriesString
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc]init];
                                          inAndOutCategoriesArray = [converter convertToObjects:venues];
                                          
                                          [self addSport:inAndOutCategoriesArray];
                                      }
                                  }];
}

- (void)getOutAndAboutForLocation:(CLLocation *)location
{
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(kMinimumFoursquareRequestRadius)
                                categoryId:kOutAboutCategoriesString
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc]init];
                                          outAndAboutCategoriesArray = [converter convertToObjects:venues];
                                          
                                          [self addSport:outAndAboutCategoriesArray];
                                      }
                                  }];
}

- (void)getRockOnForLocation:(CLLocation *)location
{
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(kMinimumFoursquareRequestRadius)
                                categoryId:kRockOnCategoriesString
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc]init];
                                          rockOnCategoriesArray = [converter convertToObjects:venues];
                                          
                                          [self addSport:rockOnCategoriesArray];
                                      }
                                  }];
}

- (void)addSport:(NSArray*)spots
{
    NSMutableArray *annotationsToAdd = [NSMutableArray array];
    NSMutableArray *annotationsToRemove = [NSMutableArray array];
    //Hadle this ASAP
    if([spots count]>1){
    for (FSVenue *dict in spots)
    {
        SpotAnnotation *ann = [SpotAnnotation sgySpotAnnotationFromFoursquareInfo:dict CurrLocation:currentLocation];
        
        SpotAnnotation *existingAnnotation = [foursquareSpotAnnotations objectForKey:ann.foursquareId];
        if(existingAnnotation)
        {
            if(![existingAnnotation isEqual:ann])
            {
                [foursquareSpotAnnotations removeObjectForKey:existingAnnotation.foursquareId];
                [foursquareSpotAnnotations setObject:ann forKey:ann.foursquareId];
                [annotationsToRemove addObject:existingAnnotation];
                [annotationsToAdd addObject:ann];
            }
            else
            {
                existingAnnotation.hereNow = ann.hereNow;
                [annotationsToRemove addObject:existingAnnotation];
                [annotationsToAdd addObject:existingAnnotation];
            }
        }
        else
        {
            [annotationsToAdd addObject:ann];
            [foursquareSpotAnnotations setObject:ann forKey:ann.foursquareId];
        }
    }
}
    if([annotationsToRemove count] > 0)
        [_delegate spotManage:self didRemoveSpots:[annotationsToRemove copy]];
    if([annotationsToAdd count] > 0)
        [_delegate spotManage:self didAddSpots:[annotationsToAdd copy]];
}

-(NSArray *)getSpots
{
    // Go through all the spots and just retrieve the annotations with deals
    NSMutableArray *deals = [NSMutableArray array];
    
    [foursquareSpotAnnotations enumerateKeysAndObjectsUsingBlock:^(id key, SpotAnnotation* obj, BOOL *stop) {
        [deals addObject:obj];
    }];
    
    return [deals copy];
}

- (void)getFavoriteSpot
{
    PFQuery *sports = [PFQuery queryWithClassName:@"Spot"];
    [sports findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSString *topFavoriteFoursquareId = @"";
        int topCount = 0;
        for(PFObject *retrievedSpot in objects){
            
            NSArray *arrFav = retrievedSpot[@"like_users"];
            if (topCount < arrFav.count)
            {
                topFavoriteFoursquareId = retrievedSpot[@"fs_id"];
                SpotAnnotation *topAnnotation = [foursquareSpotAnnotations objectForKey:topFavoriteFoursquareId];
                
                if ([topAnnotation.deal isActive])
                {
                    topCount = (int)arrFav.count;
                }
            }
        }
        
        SpotAnnotation *topAnnotation = [foursquareSpotAnnotations objectForKey:topFavoriteFoursquareId];

        [_delegate spotManage:self didGetFavorite:topAnnotation];
    }];
}

- (void)updateCurrentLocation:(CLLocation*)location
{
    NSLog(@"installationId %@",[PFInstallation currentInstallation].installationId);
    
    PFQuery *query = [PFQuery queryWithClassName:@"LastLocation"];
    [query whereKey:@"identifier" equalTo:[PFInstallation currentInstallation].installationId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count)
        {
            PFObject* object = [objects firstObject];
            [object setObject:[PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] forKey:@"location"];
            [object saveInBackground];
        }
        else
        {
            PFObject *object = [PFObject objectWithClassName:@"LastLocation"];
            [object setObject:[PFInstallation currentInstallation].installationId forKey:@"identifier"];
            [object setObject:[PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] forKey:@"location"];
            [object saveInBackground];
        }
    }];
}

-(void)doneRetrievingFavorites:(NSArray *)favorites
{
    [thisUsersFavoriteSpots addObjectsFromArray:favorites];
}

-(BOOL)hasUserFavoritedSpotWithFoursquareId:(NSString *)foursquareId
{
    return [thisUsersFavoriteSpots containsObject:foursquareId];
}

-(void)toggleFavoriteForSpotWithFoursquareId:(NSString *)foursquareId
{
    if ([thisUsersFavoriteSpots containsObject:foursquareId]) {
        [self doUnfavoriteSpot:foursquareId];
        [thisUsersFavoriteSpots removeObject:foursquareId];
    } else {
        [self doFavoriteSpot:foursquareId];
        [thisUsersFavoriteSpots addObject:foursquareId];
    }
}

-(void)doFavoriteSpot:(NSString *)foursquareId
{
    PFObject *favoriteRow = [PFObject objectWithClassName:@"Favorites"];
    
    [favoriteRow setObject:foursquareId forKey:@"foursquare_id"];
    [favoriteRow setObject:[PFInstallation currentInstallation].installationId forKey:@"installation"];
    
    [favoriteRow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Spot"];
            [query whereKey:@"fs_id" equalTo:foursquareId];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for (PFObject* sport in objects)
                {
                    NSMutableArray *arrFav = sport[@"like_users"];
                    if (arrFav == nil)
                        arrFav = [NSMutableArray array];
                    
                    [arrFav addObject:[PFInstallation currentInstallation].installationId];
                    sport[@"like_users"] = arrFav;
                    
                    [sport setObject:foursquareId forKey:@"fs_id"];
                    
                    [sport saveInBackground];
                    break;
                }
            }];
            
            
        }
    }];
}

-(void)doUnfavoriteSpot:(NSString *)foursquareId
{    
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"foursquare_id" equalTo:foursquareId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            
            for (PFObject* obj in objects)
            {
                if ([obj[@"installation"] isEqualToString:[PFInstallation currentInstallation].installationId])
                {
                    [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded)
                        {
                            PFQuery *query = [PFQuery queryWithClassName:@"Spot"];
                            [query whereKey:@"fs_id" equalTo:foursquareId];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                
                                for (PFObject* sport in objects)
                                {
                                    NSMutableArray *arrFav = sport[@"like_users"];
                                    if (arrFav == nil)
                                        return ;
                                    
                                    [arrFav removeObject:[PFInstallation currentInstallation].installationId];
                                    sport[@"like_users"] = arrFav;
                                    
                                    [sport saveInBackground];
                                    break;
                                }
                            }];
                        }
                    }];
                    break;
                }
            }
        }
    }];
}

@end
