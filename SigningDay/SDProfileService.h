//
//  SDProfileService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/6/12.
//
//

#import <Foundation/Foundation.h>

@interface SDProfileService : NSObject

+ (void)getProfileInfoForUserIdentifier:(NSNumber *)identifier completionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock;
+ (void)postNewProfileFieldsForUserWithIdentifier:(NSNumber *)identifier name:(NSString *)name bio:(NSString *)bio completionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock;
+ (void)uploadAvatar:(UIImage *)avatar forUserIdentifier:(NSNumber *)identifier completionBlock:(void (^)(void))completionBlock;
+ (void)getAvatarImageFromFacebookAndSendItToServerForUserIdentifier:(NSNumber *)identifier completionHandler:(void (^)(void))completionHandler;
+ (void)deleteAvatar;

@end
