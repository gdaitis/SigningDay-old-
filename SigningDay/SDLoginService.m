//
//  SDLoginService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDLoginService.h"
#import "SDAPIClient.h"
#import "STKeychain.h"
#import "Master.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"
#import "SDErrorService.h"

NSString * const kSDLoginServiceUserDidLogoutNotification = @"SDLoginServiceUserDidLogoutNotificationName";

@implementation SDLoginService

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password facebookToken:(NSString *)facebookToken successBlock:(void (^)(void))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (username)
        [parameters setValue:username forKey:@"Username"];
    if (password)
        [parameters setValue:password forKey:@"Password"];
    if (facebookToken)
        [parameters setValue:facebookToken forKey:@"FBAuthToken"];
    NSString *deviceName = [[UIDevice currentDevice] name];
    [parameters setValue:deviceName forKey:@"DeviceName"];
    NSString *systemName = [[UIDevice currentDevice] systemName];
    [parameters setValue:systemName forKey:@"DeviceOS"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    [parameters setValue:osVersion forKey:@"DeviceOSVersion"];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *deviceToken = appDelegate.deviceToken;
    if (deviceToken == nil) {
        deviceToken = @"invalid_token";
    }

    [parameters setValue:deviceToken forKey:@"DeviceToken"];

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Logging in";
    
    [[SDAPIClient sharedClient] setRestTokenHeaderWithToken:[STKeychain getPasswordForUsername:@"initialApiKey" andServiceName:@"SigningDay" error:nil]];
    [[SDAPIClient sharedClient] postPath:@"sd/clientdevices.json" 
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                                     
                                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                     NSString *anUsername;
                                     if (!username) {
                                         anUsername = [[JSON objectForKey:@"User"] valueForKey:@"Username"];
                                     } else {
                                         anUsername = username;
                                     }
                                     [[NSUserDefaults standardUserDefaults] setValue:anUsername forKey:@"username"];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     
                                     NSString *apiKey = [JSON objectForKey:@"ApiKey"]; 
                                     NSError *error;
                                     [STKeychain storeUsername:anUsername andPassword:apiKey forServiceName:@"SigningDay" updateExisting:YES error:&error];
                                     if (error) {
                                         NSLog(@"Error while saving to keychain.");
                                         exit(-1);
                                     }
                                     
                                     [[SDAPIClient sharedClient] setRestTokenHeaderWithToken:apiKey];
                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loggedIn"];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:anUsername];
                                     if (!master) {
                                         master = [Master MR_createInContext:context];
                                         master.username = anUsername;
                                         master.identifier = @([JSON[@"User"][@"Id"] intValue]);
                                         master.photoGalleryId = @([JSON[@"PhotoGalleryId"] intValue]);
                                         master.videoGalleryId = @([JSON[@"VideoGalleryId"] intValue]);
                                         
                                     }
                                     if (facebookToken)
                                         master.facebookSharingOn = [NSNumber numberWithBool:YES];
                                     else
                                         master.facebookSharingOn = [NSNumber numberWithBool:NO];
                                     
                                     [context MR_save];
                                                                          
                                     if (block)
                                         block();
                                 } 
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                                     
                                     [SDErrorService handleError:error withOperation:operation];
                                 }];
}

+ (void)logout
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.fbSession close];
    appDelegate.twitterAccount = nil;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    master.facebookSharingOn = [NSNumber numberWithBool:NO];
    [context MR_save];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"loggedIn"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDLoginServiceUserDidLogoutNotification object:nil];
}

@end
