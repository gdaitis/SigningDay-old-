//
//  SDTabBarController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXCustomTabBar.h"
#import "SDConversationsViewController.h"
#import "SDProfileViewController.h"

extern NSString * const kSDTabBarShouldHideNotification;
extern NSString * const kSDTabBarShouldShowNotification;

@interface SDTabBarController : RXCustomTabBar <SDConversationsViewControllerDelegate, SDProfileViewControllerDelegate>

@end
