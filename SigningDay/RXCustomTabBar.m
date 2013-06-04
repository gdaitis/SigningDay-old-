//
//  RumexCustomTabBar.m
//
//
//  Created by Oliver Farago on 19/06/2010.
//  Copyright 2010 Rumex IT All rights reserved.
//

#import "RXCustomTabBar.h"

@implementation RXCustomTabBar

@synthesize btn1, btn2, btn3;
@synthesize bottomShadowImageView = _bottomShadowImageView;

- (void)viewDidLoad
{
    [self hideTabBar];
	[self addCustomElements];
    
    [super viewDidLoad];
}

- (void)hideTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
			break;
		}
	}
}

- (void)hideNewTabBar
{
    [UIView beginAnimations:nil context:nil];
    self.btn1.alpha = 0;
    self.btn2.alpha = 0;
    self.btn3.alpha = 0;
    self.bottomShadowImageView.alpha = 0;
    [UIView commitAnimations];
}

- (void)showNewTabBar
{
    [UIView beginAnimations:nil context:nil];
    self.btn1.alpha = 1;
    self.btn2.alpha = 1;
    self.btn3.alpha = 1;
    self.bottomShadowImageView.alpha = 1;
    [UIView commitAnimations];
}

-(void)addCustomElements
{
	// Initialise our two images
	UIImage *btnImage = [UIImage imageNamed:@"conversations_tab_inactive.png"];
	UIImage *btnImageSelected = [UIImage imageNamed:@"conversations_tab_active.png"];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	
	self.btn1 = [UIButton buttonWithType:UIButtonTypeCustom]; //Setup the button
	btn1.frame = CGRectMake(0, screenSize.height - 60, 105, 60); // Set the frame (size and position) of the button)
	[btn1 setBackgroundImage:btnImage forState:UIControlStateNormal]; // Set the image for the normal state of the button
	[btn1 setBackgroundImage:btnImageSelected forState:UIControlStateSelected]; // Set the image for the selected state of the button
    [btn1 setBackgroundImage:btnImageSelected forState:UIControlStateHighlighted];
	[btn1 setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
	[btn1 setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
	
	// Now we repeat the process for the other buttons
	btnImage = [UIImage imageNamed:@"photo_tab_inactive.png"];
	self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn2.frame = CGRectMake(105, screenSize.height - 60, 110, 60);
	[btn2 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn2 setTag:-1];
	
	btnImage = [UIImage imageNamed:@"profile_tab_inactive.png"];
	btnImageSelected = [UIImage imageNamed:@"profile_tab_active.png"];
	self.btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn3.frame = CGRectMake(215, screenSize.height - 60, 105, 60);
	[btn3 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn3 setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
    [btn3 setBackgroundImage:btnImageSelected forState:UIControlStateHighlighted];
	[btn3 setTag:1];
	
	// Add my new buttons to the view
	[self.view addSubview:btn1];
	[self.view addSubview:btn2];
	[self.view addSubview:btn3];
	
	// Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	[btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_shadow.png"]];
    self.bottomShadowImageView.frame = CGRectMake(0, screenSize.height - 65, 320, 5);
    [self.view addSubview:self.bottomShadowImageView];
}

- (void)buttonClicked:(id)sender
{
	int tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)selectTab:(int)tabID
{
    if (tabID == -1) {
        return;
    }
	switch(tabID)
	{
		case 0:
			[btn1 setSelected:true];
			[btn2 setSelected:false];
			[btn3 setSelected:false];
			break;
		case 1:
			[btn1 setSelected:false];
			[btn2 setSelected:false];
			[btn3 setSelected:true];
			break;
	}
	self.selectedIndex = tabID;
}

@end
