//
//  SDFollowingCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/13/13.
//
//

#import <UIKit/UIKit.h>

@interface SDFollowingCell : UITableViewCell

@property (nonatomic, strong) NSString *userImageUrlString;
@property (weak, nonatomic) IBOutlet UILabel *usernameTitle;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (assign, nonatomic) BOOL followingBtnSelected;

@end
