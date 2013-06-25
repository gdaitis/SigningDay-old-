//
//  SDErrorService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/27/12.
//
//

#import "SDErrorService.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperation.h"

@implementation SDErrorService

+ (void)handleError:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation
{
    NSLog(@"Request: %@", [[operation request] URL]);
    NSLog(@"Request headers: %@", [[operation request] allHTTPHeaderFields]);
    NSLog(@"Request body: %@", [[NSString alloc] initWithData:[[operation request] HTTPBody] encoding:NSUTF8StringEncoding]);
    
    if (error.code == -1011) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Invalid username or password"
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
