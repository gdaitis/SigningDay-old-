//
//  SDMessageCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/1/12.
//
//

#import "SDMessageCell.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDImageService.h"
#import "UIImage+Crop.h"

@interface SDMessageCell ()

@end

@implementation SDMessageCell

@synthesize userImageView = _userImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize dateLabel = _dateLabel;
@synthesize messageTextLabel = _messageTextLabel;
@synthesize message = _message;
@synthesize bottomLineView = _bottomLineView;
@synthesize userImageUrlString = _userImageUrlString;

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.dateLabel.textColor = [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1];
    self.messageTextLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    
    CGSize size = [self.message.text sizeWithFont:[UIFont fontWithName:@"Arial" size:13] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    self.messageTextLabel.frame = CGRectMake(64, 31, size.width + 5, size.height);
    CGFloat height = size.height + 30 + 12;
    if (height < 67) {
        height = 67;
    }
    self.bottomLineView.frame = CGRectMake(0, height, 320, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
