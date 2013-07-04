//
//  User.h
//  SigningDay
//
//  Created by Lukas Kekys on 7/2/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, Master, Message;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfFollowers;
@property (nonatomic, retain) NSNumber * numberOfFollowing;
@property (nonatomic, retain) NSNumber * numberOfPhotos;
@property (nonatomic, retain) NSNumber * numberOfVideos;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSDate * followingRelationshipCreated;
@property (nonatomic, retain) NSDate * followerRelationshipCreated;
@property (nonatomic, retain) NSSet *authorOf;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) Master *followedBy;
@property (nonatomic, retain) Master *following;
@property (nonatomic, retain) Master *master;
@property (nonatomic, retain) NSSet *messages;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAuthorOfObject:(Conversation *)value;
- (void)removeAuthorOfObject:(Conversation *)value;
- (void)addAuthorOf:(NSSet *)values;
- (void)removeAuthorOf:(NSSet *)values;

- (void)addConversationsObject:(Conversation *)value;
- (void)removeConversationsObject:(Conversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
