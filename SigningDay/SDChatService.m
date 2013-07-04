//
//  SDChatService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDChatService.h"
#import "SDAPIClient.h"
#import "User.h"
#import "Master.h"
#import "Message.h"
#import "STKeychain.h"
#import "NSString+HTML.h"
#import "SDErrorService.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"


@interface SDChatService ()

+ (void)performConversationParsingAndStoringForJSON:(NSDictionary *)JSON forReadMessages:(BOOL)isRead;

@end

@implementation SDChatService

+ (void)performConversationParsingAndStoringForJSON:(NSDictionary *)JSON forReadMessages:(BOOL)isRead
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSArray *parsedConversations = [JSON objectForKey:@"Conversations"];
    for (NSDictionary *conversationDictionary in parsedConversations) {
        NSString *identifier = [conversationDictionary valueForKey:@"Id"];
        Conversation *conversation = [Conversation MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
        if (!conversation) {
            conversation = [Conversation MR_createInContext:context];
            conversation.identifier = identifier;
        }
        conversation.shouldBeDeleted = [NSNumber numberWithBool:NO];
        
        NSDictionary *lastMessageDictionary = [conversationDictionary objectForKey:@"LastMessage"];
        NSString *dateString = [[lastMessageDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *date = [dateFormatter dateFromString:dateString];
        conversation.lastMessageDate = date;
        conversation.lastMessageText = [[lastMessageDictionary objectForKey:@"Body"] stringByConvertingHTMLToPlainText];
        
        NSDictionary *authorDictionary = [conversationDictionary valueForKey:@"CreatedUser"];
        NSNumber *authorIdentifier = [NSNumber numberWithInt:[[authorDictionary valueForKey:@"Id"] intValue]];
        User *author = [User MR_findFirstByAttribute:@"identifier" withValue:authorIdentifier];
        if (!author) {
            author = [User MR_createInContext:context];
            author.identifier = authorIdentifier;
        }
        author.username = [authorDictionary valueForKey:@"Username"];
        author.avatarUrl = [authorDictionary valueForKey:@"AvatarUrl"];
        author.name = [authorDictionary valueForKey:@"DisplayName"];
        
        conversation.author = author;
        
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        NSNumber *masterUserIndentifier = master.identifier;
        NSDictionary *participantsDictionary = [conversationDictionary objectForKey:@"Participants"];
        for (NSDictionary *participantDictionary in participantsDictionary) {
            NSNumber *identifier = [NSNumber numberWithInt:[[participantDictionary valueForKey:@"Id"] intValue]];
            if (![identifier isEqualToNumber:masterUserIndentifier]) {
                NSNumber *participantUserIdentifier = [NSNumber numberWithInt:[[participantDictionary valueForKey:@"Id"] intValue]];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@",participantUserIdentifier];
                User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
                if (!user) {
                    user = [User MR_createInContext:context];
                    user.identifier = participantUserIdentifier;
                }
                user.username = [participantDictionary valueForKey:@"Username"];
                user.avatarUrl = [participantDictionary valueForKey:@"AvatarUrl"];
                user.name = [participantDictionary valueForKey:@"DisplayName"];
                user.master = master;
                [conversation addUsersObject:user];
            }
        }
        conversation.master = master;
        conversation.isRead = [NSNumber numberWithBool:[[conversationDictionary valueForKey:@"HasRead"] boolValue]];
    }
    
    [context MR_save];
}

+ (void)getConversationsForPage:(int)pageNumber withSuccessBlock:(void (^)(int totalConversationCount))block failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"conversations.json"
                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"100", @"PageSize",[NSString stringWithFormat:@"%d",pageNumber], @"PageIndex", nil]
                                success:^(AFHTTPRequestOperation *operation, id JSON) {                                    
                                    if (pageNumber == 0) {
                                        [self markAllConversationsForDeletion];
                                    }
                                    [self performConversationParsingAndStoringForJSON:JSON forReadMessages:NO];
                                    int totalConversations = [[JSON valueForKey:@"TotalCount"] intValue];
                                    if (block)
                                        block(totalConversations);
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                    [SDErrorService handleError:error withOperation:operation];
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getMessagesWithPageNumber:(int)pageNumber fromConversation:(Conversation *)conversation success:(void (^)(int totalMessagesCount))block failure:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"conversations/%@/messages.json", conversation.identifier];
    [[SDAPIClient sharedClient] getPath:path
                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"100", @"PageSize", [NSString stringWithFormat:@"%d",pageNumber], @"PageIndex", nil]
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    int totalMessages = [[JSON valueForKey:@"TotalCount"] intValue];
                                    
                                    if (pageNumber == 0) {
                                        [self markAllMessagesForDeletionForConversation:conversation];
                                    }
                                    
                                    NSArray *parsedMessages = [JSON objectForKey:@"Messages"];
                                    for (NSDictionary *messageDictionary in parsedMessages) {
                                        NSString *identifier = [messageDictionary valueForKey:@"Id"];
                                        Message *message = [Message MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                        if (!message) {
                                            message = [Message MR_createInContext:context];
                                            message.identifier = identifier;
                                        }
                                        message.shouldBeDeleted = [NSNumber numberWithBool:NO];
                                        message.conversation = conversation;
                                        NSDictionary *authorDictionary = [messageDictionary objectForKey:@"Author"];
                                        NSNumber *authorIdentifier = [NSNumber numberWithInt:[[authorDictionary valueForKey:@"Id"] intValue]];
                                        User *user = [User MR_findFirstByAttribute:@"identifier" withValue:authorIdentifier inContext:context];
                                        if (!user) {
                                            user = [User MR_createInContext:context];
                                            user.identifier = authorIdentifier;
                                        }
                                        user.avatarUrl = [authorDictionary valueForKey:@"AvatarUrl"];
                                        user.username = [authorDictionary valueForKey:@"Username"];
                                        user.name = [authorDictionary valueForKey:@"DisplayName"];
                                        
                                        message.user = user;
                                        NSString *dateString = [[messageDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                        NSDate *date = [dateFormatter dateFromString:dateString];
                                        message.date = date;
                                        message.text = [[messageDictionary objectForKey:@"Body"] stringByConvertingHTMLToPlainText];
                                    }
                                    
                                    [context MR_save];
                                    
                                    if (block) {
                                        block(totalMessages);
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [SDErrorService handleError:error withOperation:operation];
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)sendMessage:(NSString *)messageText forConversation:(Conversation *)conversation completionBlock:(void (^)(void))completionBlock
{
    NSString *subject = @"Sent from iPhone";
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:subject, @"Subject", messageText, @"Body", nil];
    
    NSString *path = [NSString stringWithFormat:@"conversations/%@/messages.json", conversation.identifier];
    [[SDAPIClient sharedClient] postPath:path
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if (completionBlock)
                                         completionBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error withOperation:operation];
                                 }];
}

+ (void)startNewConversationWithUsername:(NSString *)username text:(NSString *)text completionBlock:(void (^)(NSString *identifier))completionBlock
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"No Subject", @"Subject", text, @"Body", username, @"Usernames", nil];
    [[SDAPIClient sharedClient] postPath:@"conversations.json"
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSDictionary *conversationDictionary = [JSON objectForKey:@"Conversation"];
                                     NSString *identifier = [conversationDictionary valueForKey:@"Id"];
                                     if (completionBlock)
                                         completionBlock(identifier);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error withOperation:operation];
                                 }];
}

+ (void)setConversationToRead:(Conversation *)conversation completionBlock:(void (^)(void))completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDAPIBaseURLString]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:conversation.identifier forKey:@"ConversationId"];
    [parameters setValue:[NSString stringWithFormat:@"%d", [conversation.master.identifier integerValue]] forKey:@"ParticipantId"];
    [parameters setValue:@"true" forKey:@"IsRead"];
    
    NSString *apiKey = [STKeychain getPasswordForUsername:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]
                                           andServiceName:@"SigningDay"
                                                    error:nil];
    [httpClient setDefaultHeader:@"Rest-User-Token" value:apiKey];
    [httpClient postPath:@"sd/conversations.json"
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     conversation.isRead = [NSNumber numberWithBool:YES];
                     [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
                     int badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
                     if (badgeNumber > 0)
                         [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(badgeNumber - 1)];
                     
                     if (completionBlock)
                         completionBlock();
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [SDErrorService handleError:error withOperation:operation];
                 }];
}

+ (void)getListOfFollowingWithCompletionBlock:(void (^)(void))completionBlock
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Loading";
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    NSNumber *identifier = master.identifier;
    NSString *followersPath = [NSString stringWithFormat:@"users/%d/following.json", [identifier integerValue]];
    [[SDAPIClient sharedClient] getPath:followersPath
                             parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"100", @"PageSize", nil]
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSDictionary *followingDictionary = [JSON objectForKey:@"Following"];
                                    
                                    master.following = nil;
                                    
                                    for (NSDictionary *followingUserDictionary in followingDictionary) {
                                        NSNumber *identifier = [NSNumber numberWithInt:[[followingUserDictionary valueForKey:@"Id"] integerValue]];
                                        User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                        if (!user) {
                                            user = [User MR_createInContext:context];
                                            user.identifier = identifier;
                                            user.username = [followingUserDictionary valueForKey:@"Username"];
                                        }
                                        user.avatarUrl = [followingUserDictionary valueForKey:@"AvatarUrl"];
                                        user.name = [followingUserDictionary valueForKey:@"DisplayName"];
                                        user.followedBy = master;
                                        
                                    }
                                    [context MR_save];
                                    
                                    if (completionBlock)
                                        completionBlock();
                                    
                                    [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                                    [SDErrorService handleError:error withOperation:operation];
                                }];
}



#pragma mark deletion methods

//marks conversations for deletion
+ (void)markAllConversationsForDeletion
{
    NSArray *conversationsToBeDeleted = [Conversation MR_findAll];
    for (Conversation *conversation in conversationsToBeDeleted) {
        conversation.shouldBeDeleted = [NSNumber numberWithBool:YES];
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_save];
}

+ (void)deleteMarkedConversations
{
    NSArray *conversationsToBeDeleted = [Conversation MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"shouldBeDeleted == %@", [NSNumber numberWithBool:YES]]];
    for (Conversation *conversation in conversationsToBeDeleted) {
        [conversation MR_deleteEntity];
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_save];
    
    //setup badge on left unread conversations
    NSArray *unreadConversations = [Conversation MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isRead == %@", [NSNumber numberWithBool:NO]]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[unreadConversations count]];
}

+ (void)markAllMessagesForDeletionForConversation:(Conversation *)conversation
{
    for (Message *message in conversation.messages) {
        message.shouldBeDeleted = [NSNumber numberWithBool:YES];
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_save];
}

+ (void)deleteMarkedMessagesForConversation:(Conversation *)conversation
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSSet *messages = conversation.messages;
    for (Message *mesage in messages)
    {
        if ([mesage.shouldBeDeleted boolValue]) {
            [mesage MR_deleteInContext:context];
        }
    }
    [context MR_save];
}

@end















