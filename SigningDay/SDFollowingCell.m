//
//  SDFollowingCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/13/13.
//
//

#import "SDFollowingCell.h"
#import "SDImageService.h"
#import "AFImageRequestOperation.h"
#import "UIImage+Crop.h"

@interface SDFollowingCell ()

@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) AFImageRequestOperation *currentOperation;

@end

@implementation SDFollowingCell

@synthesize bottomLine = _bottomLine;
@synthesize userImageView = _userImageView;
@synthesize userImageUrlString = _userImageUrlString;
@synthesize usernameTitle = _usernameTitle;
@synthesize followButton = _followButton;
@synthesize followingBtnSelected = _followingBtnSelected;

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
}

- (void)setUserImageUrlString:(NSString *)userImageUrlString
{
    self.userImageView.image = [UIImage imageNamed:@"placeholder.png"];
    [[SDImageService sharedService] getImageWithURLString:userImageUrlString success:^(UIImage *image) {
        self.userImageView.image = [image imageByScalingAndCroppingForSize:CGSizeMake(48 * [UIScreen mainScreen].scale, 48 * [UIScreen mainScreen].scale)];
    }];
}

@end
