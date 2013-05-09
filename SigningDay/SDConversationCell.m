//
//  SDConversationCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDConversationCell.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDImageService.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Crop.h"

@interface SDConversationCell ()

@property (nonatomic, strong) UIImageView *highlightedImageView;

@end

@implementation SDConversationCell

@synthesize userImageView = _userImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize dateLabel = _dateLabel;
@synthesize messageTextLabel = _messageTextLabel;
@synthesize conversation = _conversation;
@synthesize bottomLineView = _bottomLineView;
@synthesize userImageUrlString = _userImageUrlString;
@synthesize highlightedImageView = _highlightedImageView;

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.dateLabel.textColor = [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1];
    self.messageTextLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1];
    
    self.highlightedImageView = [[UIImageView alloc] init];
    self.highlightedImageView.image = [UIImage imageNamed:@"highlight_yellow.png"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.highlightedImageView.frame = self.backgroundView.frame;
    
    CGSize textSize = [self.messageTextLabel.text sizeWithFont:[UIFont fontWithName:@"Arial" size:13]];
    if (textSize.width > self.messageTextLabel.frame.size.width && self.messageTextLabel.frame.size.height < 29) {
        self.messageTextLabel.frame = CGRectMake(self.messageTextLabel.frame.origin.x, self.messageTextLabel.frame.origin.y
                                                 , self.messageTextLabel.frame.size.width, self.messageTextLabel.frame.size.height + 15);
    }
}

- (void)setUserImageUrlString:(NSString *)userImageUrlString
{
    [[SDImageService sharedService] getImageWithURLString:userImageUrlString success:^(UIImage *image) {
        self.userImageView.image = [image imageByScalingAndCroppingForSize:CGSizeMake(50 * [UIScreen mainScreen].scale, 50 * [UIScreen mainScreen].scale)];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        [self.backgroundView addSubview:self.highlightedImageView];
    } else {
        [self.highlightedImageView removeFromSuperview];
    }
}

@end
