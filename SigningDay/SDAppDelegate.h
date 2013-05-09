//
//  SDAppDelegate.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>

extern NSString * const kSDPushNotificationReceivedWhileInBackgroundNotification;
extern NSString * const kSDPushNotificationReceivedWhileInForegroundNotification;

@interface SDAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) FBSession *fbSession;
@property (nonatomic, strong) NSString* deviceToken;
@property (nonatomic, strong) ACAccount *twitterAccount;

@end
