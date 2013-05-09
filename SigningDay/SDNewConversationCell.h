//
//  SDNewConversationCell.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/27/12.
//
//

#import <UIKit/UIKit.h>

@interface SDNewConversationCell : UITableViewCell

@property (nonatomic, strong) NSString *userImageUrlString;
@property (weak, nonatomic) IBOutlet UILabel *usernameTitle;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end
