//
//  Master.h
//  SigningDay
//
//  Created by Lukas Kekys on 7/2/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, User;

@interface Master : NSManagedObject

@property (nonatomic, retain) NSNumber * facebookSharingOn;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * photoGalleryId;
@property (nonatomic, retain) NSNumber * twitterSharingOn;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * videoGalleryId;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) NSSet *followedBy;
@property (nonatomic, retain) NSSet *following;
@property (nonatomic, retain) NSSet *users;
@end

@interface Master (CoreDataGeneratedAccessors)

- (void)addConversationsObject:(Conversation *)value;
- (void)removeConversationsObject:(Conversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

- (void)addFollowedByObject:(User *)value;
- (void)removeFollowedByObject:(User *)value;
- (void)addFollowedBy:(NSSet *)values;
- (void)removeFollowedBy:(NSSet *)values;

- (void)addFollowingObject:(User *)value;
- (void)removeFollowingObject:(User *)value;
- (void)addFollowing:(NSSet *)values;
- (void)removeFollowing:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
