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
+ (void)getMessagesWithPageNumber:(int)pageNumber fromConversation:(Conversation *)conversation success:(void (^)(int totalMessagesCount))block failure:(void (^)(void))failureBlock;
+ (void)sendMessage:(NSString *)messageText forConversation:(Conversation *)conversation completionBlock:(void (^)(void))completionBlock;
+ (void)getListOfFollowersForUserWithIdentifier:(NSNumber *)identifier withCompletionBlock:(void (^)(void))completionBlock;
+ (void)startNewConversationWithUsername:(NSString *)username text:(NSString *)text completionBlock:(void (^)(NSString *identifier))completionBlock;
+ (void)setConversationToRead:(Conversation *)conversation completionBlock:(void (^)(void))completionBlock;
+ (void)getListOfFollowingWithCompletionBlock:(void (^)(void))completionBlock;

+ (void)deleteMarkedConversations;
+ (void)deleteMarkedMessagesForConversation:(Conversation *)conversation;

@end
