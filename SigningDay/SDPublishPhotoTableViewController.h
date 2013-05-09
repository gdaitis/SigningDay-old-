//
//  SDPublishPhotoTableViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/2/12.
//
//

#import <UIKit/UIKit.h>
#import "SDEnterMediaInfoViewController.h"

@class SDPublishPhotoTableViewController;

@protocol SDPublishPhotoTableViewControllerDelegate <NSObject>

@required

- (UIImage *)capturedImageFromDelegate;

@end

@interface SDPublishPhotoTableViewController : SDEnterMediaInfoViewController

@property (nonatomic, strong) id <SDPublishPhotoTableViewControllerDelegate> delegate;

- (IBAction)publishPhotoPressed:(id)sender;

@end
