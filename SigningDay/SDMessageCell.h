//
//  SDMessageCell.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/1/12.
//
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface SDMessageCell : UITableViewCell

@property (nonatomic, strong) Message *message;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageTextLabel;
@property (nonatomic, strong) NSString *userImageUrlString;

@end
