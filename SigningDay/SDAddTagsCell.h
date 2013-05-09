//
//  SDAddTagsCell.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import <UIKit/UIKit.h>

@interface SDAddTagsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (nonatomic, strong) NSString *userAvatarUrlString;
@property (nonatomic) BOOL isChecked;

@end
