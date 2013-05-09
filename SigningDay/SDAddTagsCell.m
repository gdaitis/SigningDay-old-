//
//  SDAddTagsCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import "SDAddTagsCell.h"
#import "SDImageService.h"
#import "UIImage+Crop.h"

@interface SDAddTagsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end

@implementation SDAddTagsCell

@synthesize checkboxImageView = _checkboxImageView;
@synthesize bottomLine = _bottomLine;
@synthesize userImageView = _userImageView;
@synthesize userTitleLabel = _userTitleLabel;
@synthesize userAvatarUrlString = _userAvatarUrlString;
@synthesize isChecked = _isChecked;

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.bottomLine.backgroundColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.backgroundView.backgroundColor = [UIColor colorWithRed:207.0f/255.0f green:181.0f/255.0f blue:21.0f/255.0f alpha:1];
    } else {
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setUserAvatarUrlString:(NSString *)userAvatarUrlString
{
    [[SDImageService sharedService] getImageWithURLString:userAvatarUrlString
                                                  success:^(UIImage *image) {
        self.userImageView.image = [image imageByScalingAndCroppingForSize:CGSizeMake(48 * [UIScreen mainScreen].scale, 48 * [UIScreen mainScreen].scale)];
    }];
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    
    if (isChecked) {
        self.checkboxImageView.image = [UIImage imageNamed:@"check_selected.png"];
    } else {
        self.checkboxImageView.image = [UIImage imageNamed:@"check_unselected.png"];
    }
}

@end
