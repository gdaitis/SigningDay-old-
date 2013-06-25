//
//  SDFollowingService.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/14/13.
//
//

#import "SDFollowingService.h"
#import "SDAPIClient.h"
#import "User.h"
#import "Master.h"
#import "Conversation.h"
#import "Message.h"
#import "AFHTTPRequestOperation.h"
#import "STKeychain.h"

#import "SDAppDelegate.h"
#import "MBProgressHUD.h"
#import "SDErrorService.h"
#import "NSString+HTML.h"

@interface SDFollowingService ()

@end

@implementation SDFollowingService

+ (void)getListOfFollowingsForUserWithIdentifier:(NSNumber *)identifier forPage:(int)pageNumber withCompletionBlock:(void (^)(int totalFollowingCount))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"users/%d/following.json", [identifier integerValue]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"100", @"PageSize",[NSString stringWithFormat:@"%d",pageNumber], @"PageIndex", nil];
    
    [[SDAPIClient sharedClient] getPath:path
                             parameters:dict
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    int totalUserCount = [[JSON valueForKey:@"TotalCount"] intValue];
                                    NSLog(@"total followings = %d",totalUserCount);
                                    
                                    NSArray *followings = [JSON objectForKey:@"Following"];
                                    NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:masterUsername inContext:context];
                                    
                                    for (NSDictionary *userInfo in followings) {
                                        NSNumber *followingsUserIdentifier = [userInfo valueForKey:@"Id"];
                                        
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", followingsUserIdentifier];
                                        User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
                                        if (!user) {
                                            user = [User MR_createInContext:context];
                                            user.identifier = [NSNumber numberWithInt:[[userInfo valueForKey:@"Id"] integerValue]];
                                            user.username = [userInfo valueForKey:@"Username"];
                                            user.master = master;
                                        }
                                        user.followedBy = master;
                                        user.avatarUrl = [userInfo valueForKey:@"AvatarUrl"];
                                        user.name = [userInfo valueForKey:@"DisplayName"];
                                    }
                                    [context MR_save];
                                    
                                    if (completionBlock)
                                        completionBlock(totalUserCount);
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [SDErrorService handleError:error];
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getListOfFollowersForUserWithIdentifier:(NSNumber *)identifier forPage:(int)pageNumber withCompletionBlock:(void (^)(int totalFollowerCount))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"users/%d/followers.json", [identifier integerValue]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"100", @"PageSize",[NSString stringWithFormat:@"%d",pageNumber], @"PageIndex", nil];
    
    [[SDAPIClient sharedClient] getPath:path
                             parameters:dict
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:masterUsername inContext:context];
                                    
                                    master.followedBy = nil;
                                    int totalUserCount = [[JSON valueForKey:@"TotalCount"] intValue];
                                    
                                    NSLog(@"total followers = %d",totalUserCount);
                                    
                                    NSArray *followers = [JSON objectForKey:@"Followers"];
                                    for (NSDictionary *userInfo in followers) {
                                        NSNumber *followersUserIdentifier = [userInfo valueForKey:@"Id"];
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", followersUserIdentifier];
                                        User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
                                        if (!user) {
                                            user = [User MR_createInContext:context];
                                            user.identifier = [NSNumber numberWithInt:[[userInfo valueForKey:@"Id"] integerValue]];
                                            user.username = [userInfo valueForKey:@"Username"];
                                            user.master = master;
                                        }
                                        user.following = master;
                                        user.avatarUrl = [userInfo valueForKey:@"AvatarUrl"];
                                        user.name = [userInfo valueForKey:@"DisplayName"];
                                    }
                                    [context MR_save];
                                    
                                    if (completionBlock)
                                        completionBlock(totalUserCount);
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [SDErrorService handleError:error];
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)unfollowUserWithIdentifier:(NSNumber *)identifier withCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDAPIBaseURLString]];
    NSString *apiKey = [STKeychain getPasswordForUsername:username andServiceName:@"SigningDay" error:nil];
    [httpClient setDefaultHeader:@"Rest-User-Token" value:apiKey];
    
    NSString *path = [NSString stringWithFormat:@"users/%d/following/%d.json", [master.identifier integerValue], [identifier integerValue]];
    [httpClient setDefaultHeader:@"Rest-Method" value:@"DELETE"];
    
    [httpClient postPath:path
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completionBlock)
                         completionBlock();
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [SDErrorService handleError:error];
                     if (failureBlock)
                         failureBlock();
                 }];
}

+ (void)followUserWithIdentifier:(NSNumber *)identifier withCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[identifier stringValue] forKey:@"FollowingId"];
    
    NSString *path = [NSString stringWithFormat:@"users/%d/following.json", [master.identifier integerValue]];
    [[SDAPIClient sharedClient] postPath:path
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     if (completionBlock)
                                         completionBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error];
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

#pragma mark - Search webservice

+ (void)getListOfFollowingsForUserWithIdentifier:(NSNumber *)identifier withSearchString:(NSString *)searchString withCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"sd/following.json"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"10", @"MaxRows",[NSString stringWithFormat:@"%d",[identifier intValue]], @"UserId",searchString, @"SearchString", nil];
    
    [[SDAPIClient sharedClient] postPath:path
                              parameters:dict
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                     
                                     NSArray *results = [JSON objectForKey:@"Results"];
                                     NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:masterUsername inContext:context];
                                     
                                     for (NSDictionary *userInfo in results) {
                                         
                                         NSNumber *followingsUserIdentifier = [userInfo valueForKey:@"UserId"];
                                         User *user = [User MR_findFirstByAttribute:@"identifier" withValue:followingsUserIdentifier];
                                         
                                         if (!user) {
                                             user = [User MR_createInContext:context];
                                             user.identifier = followingsUserIdentifier;
                                             user.username = [userInfo valueForKey:@"Username"];
                                         }
                                         user.master = master;
                                         user.followedBy = master;
                                         user.avatarUrl = [userInfo valueForKey:@"AvatarUrl"];
                                         user.name = [userInfo valueForKey:@"DisplayName"];
                                         
                                     }
                                     [context MR_save];
                                     
                                     if (completionBlock)
                                         completionBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error];
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}


+ (void)getListOfFollowersForUserWithIdentifier:(NSNumber *)identifier withSearchString:(NSString *)searchString withCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock
{
    
    NSString *path = [NSString stringWithFormat:@"sd/followers.json"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"10", @"MaxRows",[NSString stringWithFormat:@"%d",[identifier intValue]], @"UserId",searchString, @"SearchString", nil];
    
    [[SDAPIClient sharedClient] postPath:path
                              parameters:dict
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                     NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:masterUsername inContext:context];
                                     
                                     NSArray *results = [JSON objectForKey:@"Results"];
                                     for (NSDictionary *userInfo in results) {
                                         
                                         NSNumber *followingsUserIdentifier = [userInfo valueForKey:@"UserId"];
                                         User *user = [User MR_findFirstByAttribute:@"identifier" withValue:followingsUserIdentifier];
                                         
                                         if (!user) {
                                             user = [User MR_createInContext:context];
                                             user.identifier = followingsUserIdentifier;
                                             user.username = [userInfo valueForKey:@"Username"];
                                         }
                                         
                                         user.master = master;
                                         user.following = master;
                                         user.avatarUrl = [userInfo valueForKey:@"AvatarUrl"];
                                         user.name = [userInfo valueForKey:@"DisplayName"];
                                         
                                         if (![[userInfo valueForKey:@"CanFollow"] boolValue]) {
                                             //can't follow (isFollowing master user)
                                             user.followedBy = master;
                                         }
                                         else {
                                             //not following
                                             user.followedBy = nil;
                                         }
                                     }
                                     [context MR_save];
                                     
                                     if (completionBlock)
                                         completionBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error];
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}


#pragma mark - User deletion

+ (void)deleteUnnecessaryUsers
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *masterUsernamePredicate = [NSPredicate predicateWithFormat:@"master.username like %@", username];
    NSArray *userArray = [User MR_findAllSortedBy:@"username" ascending:YES withPredicate:masterUsernamePredicate];
    
    for (User *user in userArray) {
        if (!user.followedBy && !user.following) {
            
            if ([user.conversations count] == 0) {
                //user doesn't have mutual conversation, and is not being followed or following master user, so it is going to be deleted
                if (![user.username isEqualToString:username]) {
                    //not master user can delete
                    [context deleteObject:user];
                }
            }
        }
    }
    [context MR_save];
}

+ (void)removeFollowing:(BOOL)removeFollowing andFollowed:(BOOL)removeFollowed
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    if (master) {
        if (removeFollowed) {
            master.following = nil;
        }
        if (removeFollowing) {
            master.followedBy = nil;
        }
        
        [SDFollowingService deleteUnnecessaryUsers];
    }
}



@end
