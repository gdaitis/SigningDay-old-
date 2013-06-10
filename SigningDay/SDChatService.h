//
//  SDChatService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conversation.h"

@interface SDChatService : NSObject

+ (void)getConversationsForPage:(int)pageNumber withSuccessBlock:(void (^)(int totalConversationCount))block failureBlock:(void (^)(void))failureBlock;
+ (void)getMessagesFromConversation:(Conversation *)conversation success:(void (^)(void))block failure:(void (^)(void))failureBlock;
+ (void)sendMessage:(NSString *)messageText forConversation:(Conversation *)conversation completionBlock:(void (^)(void))completionBlock;
+ (void)getListOfFollowersForUserWithIdentifier:(NSNumber *)identifier withCompletionBlock:(void (^)(void))completionBlock;
+ (void)startNewConversationWithUsername:(NSString *)username text:(NSString *)text completionBlock:(void (^)(NSString *identifier))completionBlock;
+ (void)setConversationToRead:(Conversation *)conversation completionBlock:(void (^)(void))completionBlock;
+ (void)getListOfFollowingWithCompletionBlock:(void (^)(void))completionBlock;

@end
