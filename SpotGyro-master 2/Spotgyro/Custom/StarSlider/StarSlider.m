//
//  StarSlider.m
//  HelloWorld
//
//  Created by Erica Sadun on 2/25/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "StarSlider.h"

#define WIDTH 65.0f
#define HEIGHT 15.0f
#define IZQ_OFF_ART	[UIImage imageNamed:@"izqTermoOff.png"]
#define IZQ_ON_ART	[UIImage imageNamed:@"izqTermoOn.png"]
#define DER_OFF_ART	[UIImage imageNamed:@"derTermoOff.png"]
#define DER_ON_ART	[UIImage imageNamed:@"derTermoOn.png"]
#define OFF_ART	[UIImage imageNamed:@"sliceOff.png"]
#define ON_ART	[UIImage imageNamed:@"sliceOn.png"]

@implementation StarSlider
@synthesize value;

-(void)setThermoTo:(int)val
{
    // Sanity check
    if(val < 0 || val > 4)
        val = 0;
    
    NSLog(@"Setting value of thermometer to %d", val);
    int newValue = 0;
	UIImageView *changedView = nil;
    int currentI = 0;
	for (UIImageView *eachItem in [self subviews])
    {
		if (currentI >= val)
		{
            if (currentI == 0) {
                eachItem.image = IZQ_OFF_ART;
            }
            else if(currentI == 3)
            {
                eachItem.image = DER_OFF_ART;            
            }
            else
            {
                eachItem.image = OFF_ART;
            }
            
		}
		else 
		{
			changedView = eachItem;
            
            
            if (currentI == 0) {
                eachItem.image = IZQ_ON_ART;
            }
            else if(currentI == 3)
            {
                eachItem.image = DER_ON_ART;            
            }
            else
            {
                eachItem.image = ON_ART;
            }
            
            //			eachItem.image = ON_ART;
			newValue++;
		}
        currentI++;
    }
    
	if (self.value != newValue)
	{
		self.value = newValue;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
        
		// Animate the changed view
        //		[UIView animateWithDuration:0.15f 
        //						 animations:^{changedView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);}
        //						 completion:^(BOOL done){[UIView animateWithDuration:0.1f animations:^{changedView.transform = CGAffineTransformIdentity;}];}];
	}	
}

- (id) initWithFrame: (CGRect) aFrame
{
	if (self = [super initWithFrame:aFrame])
	{
		float minimumWidth = 20.f; // * 8.0f; // 5 stars, spaced between + 1/2 size on each end
		float minimumHeight = 15.0f;
        
		// This control uses a minimum 260x34 sized frame
		self.frame = CGRectMake(0.0f, 0.0f, MAX(minimumWidth, aFrame.size.width), MAX(minimumHeight, aFrame.size.height));
        
		// Add stars -- initially assuming fixed width
		float offsetCenter = WIDTH/2;
		for (int i = 1; i <= 4; i++)
		{
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, WIDTH, HEIGHT)];
            if (i == 1) {
                imageView.image = IZQ_OFF_ART;
            }
            else if(i == 4)
            {
                imageView.image = DER_OFF_ART;            
            }
            else
            {
                imageView.image = OFF_ART;
            }			
			imageView.center = CGPointMake(offsetCenter, self.frame.size.height / 2.0f);
			offsetCenter += WIDTH; //* 1.5f;
			[self addSubview:imageView];
		}
	}
    
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];
    
	return self;
}

- (id) init
{
	return [self initWithFrame:CGRectZero];
}

+ (id) control
{
	return [[self alloc] init];
}

- (void) updateValueAtPoint: (CGPoint) p
{
	int newValue = 0;
	UIImageView *changedView = nil;
    int currentI = 0;
	for (UIImageView *eachItem in [self subviews])
    {
		if (p.x < eachItem.frame.origin.x)
		{
            if (currentI == 0) {
                eachItem.image = IZQ_OFF_ART;
            }
            else if(currentI == 3)
            {
                eachItem.image = DER_OFF_ART;            
            }
            else
            {
                eachItem.image = OFF_ART;
            }
            
		}
		else 
		{
			changedView = eachItem;

            
            if (currentI == 0) {
                eachItem.image = IZQ_ON_ART;
            }
            else if(currentI == 3)
            {
                eachItem.image = DER_ON_ART;            
            }
            else
            {
                eachItem.image = ON_ART;
            }
            
            //			eachItem.image = ON_ART;
			newValue++;
		}
        currentI++;
    }
    
	if (self.value != newValue)
	{
		self.value = newValue;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
        
		// Animate the changed view
//		[UIView animateWithDuration:0.15f 
//						 animations:^{changedView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);}
//						 completion:^(BOOL done){[UIView animateWithDuration:0.1f animations:^{changedView.transform = CGAffineTransformIdentity;}];}];
	}	
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Establish touch down event
	CGPoint touchPoint = [touch locationInView:self];
	[self sendActionsForControlEvents:UIControlEventTouchDown];
    
	// Calcluate value
	[self updateValueAtPoint:touchPoint];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Test if drag is currently inside or outside
	CGPoint touchPoint = [touch locationInView:self];
	if (CGRectContainsPoint(self.frame, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    
	// Calculate value
	[self updateValueAtPoint:[touch locationInView:self]];
	return YES;
}

- (void) endTrackingWithTouch: (UITouch *)touch withEvent: (UIEvent *)event
{
    // Test if touch ended inside or outside
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}


- (void)cancelTrackingWithEvent: (UIEvent *) event
{
	[self sendActionsForControlEvents:UIControlEventTouchCancel];
}
@end