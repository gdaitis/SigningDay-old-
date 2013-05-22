//
//  Conversation.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Message, User;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSDate * lastMessageDate;
@property (nonatomic, retain) NSString * lastMessageText;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) Master *master;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *users;
@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
