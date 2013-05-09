//
//  SDAppDelegate.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDAppDelegate.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import "Master.h"
#import "Conversation.h"
#import "STKeychain.h"
#import "SDLoginService.h"

NSString * const kSDPushNotificationReceivedWhileInBackgroundNotification = @"SDPushNotificationReceivedWhileInBackgroundNotificationName";
NSString * const kSDPushNotificationReceivedWhileInForegroundNotification = @"SDPushNotificationReceivedWhileInForegroundNotificationName";

@implementation SDAppDelegate

@synthesize window = _window;
@synthesize fbSession = _fbSession;
@synthesize deviceToken = _deviceToken;
@synthesize twitterAccount = _twitterAccount;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    
    // Override point for customization after application launch.
    [MagicalRecord setupCoreDataStack];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Šito kaip ir nereikia, nes, appsui atsidarius, refreshinama automatiškai
//    // If it has opened from a push notification
//    if (launchOptions != nil)
//	{
//		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//		if (dictionary != nil)
//		{
//			NSLog(@"Launched from push notification: %@", dictionary);
//			[[NSNotificationCenter defaultCenter] postNotificationName:kSDPushNotificationReceivedWhileInBackgroundNotification object:nil userInfo:nil];
//		}
//	}
    [STKeychain storeUsername:@"initialApiKey" andPassword:@"OGQ3MzZ4c205cWNtbzhiaHAxYnlqNzVqcGwzcWRhdDY6aU9T" forServiceName:@"SigningDay" updateExisting:NO error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionClosed) name:FBSessionDidBecomeClosedActiveSessionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionOpened) name:FBSessionDidBecomeOpenActiveSessionNotification object:nil];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.fbSession.state == FBSessionStateCreatedOpening) {
        [self.fbSession close];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Log in process was not complete" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord saveWithBlock:nil];

    [SDLoginService logout];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.deviceToken = newToken;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        NSLog(@"Active");
        [[NSNotificationCenter defaultCenter] postNotificationName:kSDPushNotificationReceivedWhileInForegroundNotification object:nil userInfo:nil];
    }
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        NSLog(@"Inactive");
        [[NSNotificationCenter defaultCenter] postNotificationName:kSDPushNotificationReceivedWhileInBackgroundNotification object:nil userInfo:nil];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[userInfo valueForKey:@"badge"] intValue]];
	NSLog(@"Received notification: %@", userInfo);
}

#pragma mark - FBSession methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [self.fbSession handleOpenURL:url];
}

- (void)fbSessionOpened
{
    NSLog(@"Facebook session opened");
}

- (void)fbSessionClosed
{
    NSLog(@"Facebook session closed");
}

@end
