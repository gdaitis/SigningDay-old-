//
//  SDErrorService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/27/12.
//
//

#import "SDErrorService.h"
#import "MBProgressHUD.h"

@implementation SDErrorService

+ (void)handleError:(NSError *)error
{
    NSLog(@"Handling an error: %@", error);
    
    if (error.code == -1011) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Ivalid username or password"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    if (error.code == -1009) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Internet connection is down."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

+ (void)handleFacebookError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Facebook permission denied."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
