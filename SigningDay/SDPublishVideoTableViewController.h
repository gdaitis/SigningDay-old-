//
//  SDPublishVideoTableViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/2/12.
//
//

#import <UIKit/UIKit.h>
#import "SDEnterMediaInfoViewController.h"

@class SDPublishVideoTableViewController;

@protocol SDPublishVideoTableViewControllerDelegate <NSObject>

@required

- (NSURL *)urlOfVideo;

@end

@interface SDPublishVideoTableViewController : SDEnterMediaInfoViewController

@property (nonatomic, strong) id <SDPublishVideoTableViewControllerDelegate> delegate;

- (IBAction)publishVideoPressed:(id)sender;

@end
