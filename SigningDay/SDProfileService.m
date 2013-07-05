//
//  SDProfileService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/6/12.
//
//

#import "SDProfileService.h"
#import "SDAPIClient.h"
#import "User.h"
#import "Master.h"
#import "AFHTTPRequestOperation.h"
#import "STKeychain.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+fixOrientation.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"
#import "SDErrorService.h"
#import "NSString+HTML.h"

@interface SDProfileService ()

+ (void)uploadAvatarForUserIdentifier:(NSNumber *)identifier verbMethod:(NSString *)verbMethod constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block completionBlock:(void (^)(void))completionBlock;

@end

@implementation SDProfileService

+ (void)getProfileInfoForUserIdentifier:(NSNumber *)identifier completionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"users/%d.json", [identifier integerValue]];
    [[SDAPIClient sharedClient] getPath:path
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
                                    NSNumber *identifier = master.identifier;
                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                    if (!user) {
                                        user = [User MR_createInContext:context];
                                        user.identifier = identifier;
                                        user.username = username;
                                    }
                                    NSDictionary *userDictionary = [JSON valueForKey:@"User"];
                                    user.name = [userDictionary valueForKey:@"DisplayName"];
                                    user.bio = [[userDictionary valueForKey:@"Bio"] stringByConvertingHTMLToPlainText];
                                    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
                                    
                                    [context MR_save];
                                    
                                    NSString *followingPath = [NSString stringWithFormat:@"users/%d/following.json", [identifier integerValue]];
                                    [[SDAPIClient sharedClient] getPath:followingPath
                                                             parameters:nil
                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                    user.numberOfFollowing = [NSNumber numberWithInteger:[[JSON valueForKey:@"TotalCount"] integerValue]];
                                                                    NSLog(@"Following: %@", user.numberOfFollowing);
                                                                    
                                                                    [context MR_save];
                                                                    
                                                                    NSString *followersPath = [NSString stringWithFormat:@"users/%d/followers.json", [identifier integerValue]];
                                                                    [[SDAPIClient sharedClient] getPath:followersPath
                                                                                             parameters:nil
                                                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                                    
                                                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                                                    user.numberOfFollowers = [JSON valueForKey:@"TotalCount"];
                                                                                                    NSLog(@"Followers: %@", user.numberOfFollowers);
                                                                                                    
                                                                                                    [context MR_save];
                                                                                                    
                                                                                                    NSString *photosCountPath = [NSString stringWithFormat:@"media/%d/files.json", [master.photoGalleryId integerValue]];

                                                                                                    [[SDAPIClient sharedClient] getPath:photosCountPath
                                                                                                                             parameters:nil
                                                                                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                                                                    
                                                                                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                                                                                    user.numberOfPhotos = [JSON valueForKey:@"TotalCount"];
                                                                                                                                    NSLog(@"Photos: %@", user.numberOfPhotos);
                                                                                                                                    
                                                                                                                                    [context MR_save];
                                                                                                                                    
                                                                                                                                    NSString *videosCountPath = [NSString stringWithFormat:@"media/%d/files.json", [master.videoGalleryId integerValue]];
                                                                                                                                    
                                                                                                                                    [[SDAPIClient sharedClient] getPath:videosCountPath
                                                                                                                                                             parameters:nil
                                                                                                                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                                                                                                    
                                                                                                                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                                                                                                                    user.numberOfVideos = [JSON valueForKey:@"TotalCount"];
                                                                                                                                                                    NSLog(@"Videos: %@", user.numberOfVideos);
                                                                                                                                                                    
                                                                                                                                                                    [context MR_save];
                                                                                                                                                                    
                                                                                                                                                                    if (completionBlock)
                                                                                                                                                                        completionBlock();
                                                                                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                                                                    if (failureBlock)
                                                                                                                                                                        failureBlock();
                                                                                                                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                                                                                                                }];
                                                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                                    if (failureBlock)
                                                                                                                                        failureBlock();
                                                                                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                                                                                }];
                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                    if (failureBlock)
                                                                                                        failureBlock();
                                                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                                                }];
                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                    if (failureBlock)
                                                                        failureBlock();
                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                }];
                                    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock)
            failureBlock();
        [SDErrorService handleError:error withOperation:operation];
    }];
}

+ (void)postNewProfileFieldsForUserWithIdentifier:(NSNumber *)identifier
                                             name:(NSString *)name
                                              bio:(NSString *)bio
                                  completionBlock:(void (^)(void))completionBlock
                                     failureBlock:(void (^)(void))failureBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDAPIBaseURLString]];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *apiKey = [STKeychain getPasswordForUsername:username andServiceName:@"SigningDay" error:nil];
    [httpClient setDefaultHeader:@"Rest-User-Token" value:apiKey];
    
    NSString *path = [NSString stringWithFormat:@"users/%d.json", [identifier integerValue]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (name) {
        [parameters setValue:name forKey:@"DisplayName"];
    }
    if (bio) {
        [parameters setValue:bio forKey:@"Bio"];
    }
    [httpClient setDefaultHeader:@"Rest-Method" value:@"PUT"];
    [httpClient postPath:path
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                     NSDictionary *userDictionary = [JSON objectForKey:@"User"];
                     NSString *displayName = [userDictionary valueForKey:@"DisplayName"];
                     NSString *bio = [[userDictionary valueForKey:@"Bio"] stringByConvertingHTMLToPlainText];
                     
                     NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
                     User *user = [User MR_findFirstByAttribute:@"identifier" withValue:master.identifier];
                     user.name = displayName;
                     user.bio = bio;
                     [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
                     
                     if (completionBlock)
                         completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock)
            failureBlock();
        [SDErrorService handleError:error withOperation:operation];
    }];
}

+ (void)uploadAvatarForUserIdentifier:(NSNumber *)identifier
                           verbMethod:(NSString *)verbMethod
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
                      completionBlock:(void (^)(void))completionBlock
{
    
    NSString *path = [NSString stringWithFormat:@"users/%@/avatar.json", identifier];
    NSMutableURLRequest *request = [[SDAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                         path:path
                                                                   parameters:nil
                                                    constructingBodyWithBlock:block];
    [request addValue:@"PUT" forHTTPHeaderField:@"Rest-Method"];

    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Uploading avatar";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        hud.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
        if (completionBlock)
            completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", operation.request.allHTTPHeaderFields);
//        NSLog(@"%@", operation.responseString);
        if (error.code == -1011) {
            [self uploadAvatarForUserIdentifier:identifier
                                     verbMethod:@"POST"
                      constructingBodyWithBlock:block
                                completionBlock:completionBlock];
        } else {
            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            [SDErrorService handleError:error withOperation:operation];
        }
    }];
    [operation start];
}

+ (void)uploadAvatar:(UIImage *)avatar
   forUserIdentifier:(NSNumber *)identifier
     completionBlock:(void (^)(void))completionBlock
{
    [self uploadAvatarForUserIdentifier:identifier
                             verbMethod:@"POST"
              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                  
                                 NSDate *todayDateObj = [NSDate date];
                                 NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                 [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
                                 NSString *fileName = [NSString stringWithFormat:@"avatar%@.jpg", [dateFormat stringFromDate:todayDateObj]];
                  
                                 UIImage *fixedImage = [avatar fixOrientation];
                                 NSData *imageData = UIImageJPEGRepresentation(fixedImage, 1);
                                 
                                 [formData appendPartWithFileData:imageData
                                                             name:@"avatar"
                                                         fileName:fileName
                                                         mimeType:@"image/jpeg"];
                             }
                        completionBlock:completionBlock];
}

+ (void)getAvatarImageFromFacebookAndSendItToServerForUserIdentifier:(NSNumber *)identifier completionHandler:(void (^)(void))completionHandler
{
    NSString *baseUrlString = @"https://graph.facebook.com/";
    NSURL *baseUrl = [NSURL URLWithString:baseUrlString];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseUrl];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Connecting to Facebook";
    
    if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
        appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
    }
    [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error) {
            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            [SDErrorService handleFacebookError];
        } else {
            NSLog(@"FB access token: %@", [appDelegate.fbSession accessToken]);
            if (status == FBSessionStateOpen) {
                NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
                master.facebookSharingOn = [NSNumber numberWithBool:YES];
                [context MR_save];
                
                NSString *fbToken = [appDelegate.fbSession accessToken];
                NSString *path = [NSString stringWithFormat:@"me/picture/?access_token=%@", fbToken];
                                
                [client getPath:path
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, NSData *avatarData) {
                            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                            [self uploadAvatarForUserIdentifier:identifier
                                                     verbMethod:@"PUT"
                                      constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                          NSDate *todayDateObj = [NSDate date];
                                          NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                          [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
                                          NSString *fileName = [NSString stringWithFormat:@"avatar%@.jpg", [dateFormat stringFromDate:todayDateObj]];
                                          
                                          [formData appendPartWithFileData:avatarData
                                                                      name:@"avatar"
                                                                  fileName:fileName
                                                                  mimeType:@"image/jpeg"];
                                      } completionBlock:^{
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler();
                                          });
                                      }];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                            [SDErrorService handleError:error withOperation:operation];
                        }];
            }
        }
    }];
}

+ (void)deleteAvatar
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDOldAPIBaseURLString]];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *apiKey = [STKeychain getPasswordForUsername:username andServiceName:@"SigningDay" error:nil];
    [httpClient setDefaultHeader:@"Rest-User-Token" value:apiKey];
    [httpClient setDefaultHeader:@"VERB" value:@"DELETE"];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
    NSNumber *identifier = master.identifier;;
    
    NSString *path = [NSString stringWithFormat:@"membership.ashx/users/%d/avatar", [identifier integerValue]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:path parameters:nil];
    
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Deleting avatar";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Avatar deleted successfully");
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SDErrorService handleError:error withOperation:operation];
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }];
    [operation start];
}

@end





























