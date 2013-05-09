//
//  Conversation.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import "Conversation.h"
#import "Master.h"
#import "Message.h"
#import "User.h"


@implementation Conversation

@dynamic identifier;
@dynamic isRead;
@dynamic lastMessageDate;
@dynamic lastMessageText;
@dynamic shouldBeDeleted;
@dynamic author;
@dynamic master;
@dynamic messages;
@dynamic users;

@end
