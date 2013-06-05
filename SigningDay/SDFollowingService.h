//
//  SDFollowingService.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/14/13.
//
//

#import <Foundation/Foundation.h>

@interface SDFollowingService : NSObject

+ (void)getListOfFollowingsForUserWithIdentifier:(NSNumber *)identifier forPage:(int)pageNumber withCompletionBlock:(void (^)(int totalFollowingCount))completionBlock failureBlock:(void (^)(void))failureBlock;
+ (void)getListOfFollowersForUserWithIdentifier:(NSNumber *)identifier forPage:(int)pageNumber withCompletionBlock:(void (^)(int totalFollowerCount))completionBlock failureBlock:(void (^)(void))failureBlock;

//user following/unfollowing
+ (void)unfollowUserWithIdentifier:(NSNumber *)identifier withCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock;
+ (void)followUserWithIdentifier:(NSNumber *)identifier withCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock;

//delete unnecessary users
+ (void)deleteUnnecessaryUsers;
+ (void)removeFollowing:(BOOL)removeFollowing andFollowed:(BOOL)removeFollowed;

@end
