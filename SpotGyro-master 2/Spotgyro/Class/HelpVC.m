//
//  HelpVC.m
//  Spotgyro
//
//  Created by BinJin on 12/20/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "HelpVC.h"

@interface HelpVC ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 900);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBack_Action:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
