//
//  SDConversationCell.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"

@interface SDConversationCell : UITableViewCell

@property (nonatomic, strong) Conversation *conversation; 
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageTextLabel;
@property (nonatomic, strong) NSString *userImageUrlString;

@end
