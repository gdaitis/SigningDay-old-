//
//  Master.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, User;

@interface Master : NSManagedObject

@property (nonatomic, retain) NSNumber * facebookSharingOn;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * twitterSharingOn;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * photoGalleryId;
@property (nonatomic, retain) NSNumber * videoGalleryId;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *following;
@end

@interface Master (CoreDataGeneratedAccessors)

- (void)addConversationsObject:(Conversation *)value;
- (void)removeConversationsObject:(Conversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addFollowingObject:(User *)value;
- (void)removeFollowingObject:(User *)value;
- (void)addFollowing:(NSSet *)values;
- (void)removeFollowing:(NSSet *)values;

@end
