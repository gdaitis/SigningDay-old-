//
//  SDAddTagsViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import <UIKit/UIKit.h>

@class SDAddTagsViewController;

@protocol SDAddTagsViewControllerDelegate <NSObject>

@required

- (NSArray *)arrayOfAlreadySelectedTags;

@optional

- (void)addTagsViewController:(SDAddTagsViewController *)addTagsViewController
         didFinishPickingTags:(NSArray *)tagsArray;

@end

@interface SDAddTagsViewController : UITableViewController

@property (nonatomic, strong) id <SDAddTagsViewControllerDelegate> delegate;

@end
