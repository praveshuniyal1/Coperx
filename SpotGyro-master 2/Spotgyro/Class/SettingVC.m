//
//  SettingVC.m
//  Spotgyro
//
//  Created by BinJin on 12/20/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "SettingVC.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

 @interface SettingVC ()
{
    BOOL        isLinkedToFacebook;
    BOOL        isLinkedToTwitter;
    NSInteger   mapType;
    BOOL        isShowingLocation;
}

@property (weak, nonatomic) IBOutlet UIButton           *unlinkFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton           *unlinkTwitterButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;
@property (weak, nonatomic) IBOutlet UISwitch           *locationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch           *realtimeDeals;

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"showLocation"])
    {
        isShowingLocation = [(NSNumber *)[defaults valueForKey:@"showLocation"] boolValue];
        [self.locationSwitch setOn:isShowingLocation];
        NSLog(@"Read showLocation %d", isShowingLocation);
        
    }
    
    if([defaults objectForKey:@"mapType"])
    {
        mapType = [(NSNumber *)[defaults valueForKey:@"mapType"] integerValue];
        [self.mapTypeControl setSelectedSegmentIndex:mapType];
        NSLog(@"Read map type %ld", (long)mapType);
        
    }
    
    if([defaults objectForKey:@"realtimeDeals"])
    {
        [self.realtimeDeals setOn:[[defaults valueForKey:@"realtimeDeals"] boolValue]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self checkSigninStatus];
    [self updateLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnBack_Action:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)facebookButtonClicked:(id)sender
{
    if(isLinkedToFacebook) {
        [PFFacebookUtils unlinkUser:[PFUser currentUser]];
        isLinkedToFacebook = NO;
    }
    else
    {
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil];
        isLinkedToFacebook = YES;
    }
    
    [self updateLabels];
}

- (IBAction)twitterButtonClicked:(id)sender
{
    if([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFTwitterUtils unlinkUser:[PFUser currentUser]];
        isLinkedToTwitter = NO;
    }
    else {
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if(succeeded)
            {
                isLinkedToTwitter = YES;
                [self updateLabels];
            }
        }];
    }
    
    [self updateLabels];
}

- (IBAction)dealsSwitchChanged:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:self.realtimeDeals.isOn] forKey:@"realtimeDeals"];
    [defaults synchronize];
    NSLog(@"Saving realtimeDeals = %d", self.realtimeDeals.isOn);
}

-(void)updateLabels
{
    if(isLinkedToFacebook)
    {
        [self.unlinkFacebookButton setTitle:NSLocalizedString(@"Unlink from Facebook", @"Unlink from Facebook") forState:UIControlStateNormal];
    }
    else {
        [self.unlinkFacebookButton setTitle:NSLocalizedString(@"Link to Facebook", @"Link to Facebook") forState:UIControlStateNormal];
    }
    
    // Check whether we are linked with Twitter
    if(isLinkedToTwitter)
    {
        [self.unlinkTwitterButton setTitle:NSLocalizedString(@"Unlink from Twitter", @"Unlink from Twitter") forState:UIControlStateNormal];
    }
    else {
        [self.unlinkTwitterButton setTitle:NSLocalizedString(@"Link to Twitter", @"Link to Twitter") forState:UIControlStateNormal];
    }
}

-(void)checkSigninStatus
{
    // Check whether we are linked with Facebook
    if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        isLinkedToFacebook = YES;
    }
    else {
        isLinkedToFacebook = NO;
    }
    
    // Check whether we are linked with Twitter
    if([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]])
    {
        isLinkedToTwitter = YES;
    }
    else {
        isLinkedToTwitter = NO;
    }
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithInteger:self.mapTypeControl.selectedSegmentIndex] forKey:@"mapType"];
    [defaults synchronize];
    NSLog(@"Saving map type %ld", (long)self.mapTypeControl.selectedSegmentIndex);
}


- (IBAction)locationChanged:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:self.locationSwitch.isOn] forKey:@"showLocation"];
    [defaults synchronize];
    NSLog(@"Saving location %d", self.locationSwitch.isOn);
}

@end
