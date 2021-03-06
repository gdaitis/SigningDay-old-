//
//  SDFollowingViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/13/13.
//
//

#import "SDFollowingViewController.h"
#import "SDFollowingCell.h"
#import "SDFollowingService.h"
#import "SDTabBarController.h"
#import "SDNavigationController.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "SDLoginService.h"
#import "SDProfileService.h"
#import "SDUtils.h"
#import "AFNetworking.h"
#import "Master.h"
#import "UIImage+Crop.h"

@interface SDFollowingViewController ()

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableSet *userSet;        //as users who are unfollowed should still be visible in the screen, their ids' are stored in this set
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searchActive;

//Pagination properties/ to keep track of the current page ant etc.
@property (nonatomic, assign) int totalFollowers;
@property (nonatomic, assign) int totalFollowings;
@property (nonatomic, assign) int currentFollowersPage;
@property (nonatomic, assign) int currentFollowingPage;

- (void)filterContentForSearchText:(NSString*)searchText;
- (void)hideKeyboard;
- (void)reloadView;
- (void)updateInfoAndShowActivityIndicator:(BOOL)showActivityIndicator;
- (IBAction)followButtonPressed:(UIButton *)sender;

@end

@implementation SDFollowingViewController

@synthesize searchResults = _searchResults;
@synthesize searchBar     = _searchBar;

- (NSMutableSet *)userSet
{
    if (_userSet == nil) {
        _userSet = [[NSMutableSet alloc] init];
    }
    return _userSet;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    //set page to zero
    _currentFollowersPage = _currentFollowingPage = 0;
    
    //adding back button
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.tableView.clearsContextBeforeDrawing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg.png"]];
    [imageView setFrame:self.tableView.bounds];
    [self.tableView setBackgroundView:imageView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTabBarShouldHideNotification object:nil];
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        self.title = @"FOLLOWERS";
    }
    else {
        self.title = @"FOLLOWING";
    }
    [SDFollowingService removeFollowing:YES andFollowed:YES];
    [self updateInfoAndShowActivityIndicator:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTabBarShouldShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDFollowingCell *cell = (SDFollowingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - filter & info update

- (void)updateInfoAndShowActivityIndicator:(BOOL)showActivityIndicator
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    if (showActivityIndicator) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Updating list";
    }
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWING) {
        //get list of followings
        [SDFollowingService getListOfFollowingsForUserWithIdentifier:master.identifier forPage:_currentFollowingPage withCompletionBlock:^(int totalFollowingCount) {
            //refresh the view
            _totalFollowings = totalFollowingCount;
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self reloadView];
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    }
    else {
        //get list of followers
        [SDFollowingService getListOfFollowersForUserWithIdentifier:master.identifier forPage:_currentFollowersPage withCompletionBlock:^(int totalFollowerCount) {
            _totalFollowers = totalFollowerCount; //set the count to know how much we should send
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self reloadView];
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    }
}

- (void)loadMoreData
{
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        _currentFollowersPage ++;
    }
    else {
        _currentFollowingPage ++;
    }
    
    //already showing activity indicator in last cell so no need for the MBProgressHUD
    [self updateInfoAndShowActivityIndicator:NO];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.searchResults = nil;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    
    NSPredicate *masterUsernamePredicate = nil;
    int fetchLimit = 0;
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        masterUsernamePredicate = [NSPredicate predicateWithFormat:@"following.username like %@", username];
        fetchLimit = (_currentFollowersPage +1) *kMaxItemsPerPage;
        
    }
    else {
        fetchLimit = (_currentFollowingPage +1) *kMaxItemsPerPage;
        
        if (self.userSet.count > 0) {
            masterUsernamePredicate = [NSPredicate predicateWithFormat:@"identifier IN %@ OR followedBy.username like %@",self.userSet,  username];
        }
        else {
            masterUsernamePredicate = [NSPredicate predicateWithFormat:@"followedBy.username like %@", username];
        }
    }
    
    if ([searchText isEqual:@""]) {
        //seting fetch limit for pagination
        NSFetchRequest *request = [User MR_requestAllWithPredicate:masterUsernamePredicate];
        [request setFetchLimit:fetchLimit];
        //set sort descriptor
        
        NSString *sortingKey = nil;
        if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
            sortingKey = @"followerRelationshipCreated";
        }
        else {
            sortingKey = @"followingRelationshipCreated";
        }
        
        NSSortDescriptor *followingSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:NO selector:@selector(compare:)];
        [request setSortDescriptors:[NSArray arrayWithObjects:followingSortDescriptor, /*nameSortDescriptor,*/ nil]];
        self.searchResults = [User MR_executeFetchRequest:request];
    }
    else {

        NSFetchRequest *request = [User MR_requestAllWithPredicate:masterUsernamePredicate];
        [request setFetchLimit:fetchLimit];
        //set sort descriptor
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSPredicate *usernameSearchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@ OR name contains[cd] %@", searchText, searchText];
        NSArray *predicatesArray = [NSArray arrayWithObjects:masterUsernamePredicate, usernameSearchPredicate, nil];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
        [request setPredicate:predicate];
        
        self.searchResults = [User MR_executeFetchRequest:request];
    }
    [self reloadTableView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    int result = [self.searchResults count];
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        
        if ((_currentFollowersPage+1)*kMaxItemsPerPage < _totalFollowers ) {
            if (result > 0)
            {
                if ([_searchBar.text length] == 0) {
                    result ++;
                }
                else
                {
                    if (_searchActive) {
                        //search active, we show loading indicator at bottom
                        result++;
                    }
                }
            }
            else {
                if (_searchActive) {
                    //search active, we show loading indicator at bottom
                    result++;
                }
            }
        }
    }
    else {
        if ((_currentFollowingPage+1)*kMaxItemsPerPage < _totalFollowings ) {
            if (result > 0)
            {
                if ([_searchBar.text length] == 0) {
                    result ++;
                }
                else
                {
                    if (_searchActive) {
                        //search active, we show loading indicator at bottom
                        result++;
                    }
                }
            }
            else {
                if (_searchActive) {
                    //search active, we show loading indicator at bottom
                    result++;
                }
            }
        }
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.searchResults count]) {
        static NSString *followingCellID = @"FollowingCellID";
        SDFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:followingCellID];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDFollowingCell" owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                    cell = (SDFollowingCell *) currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
            }
            [cell.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.userImageView cancelImageRequestOperation];
        }
        
        cell.followButton.tag = indexPath.row;
        cell.userImageView.image = nil;
        
        User *user = [self.searchResults objectAtIndex:indexPath.row];
        cell.usernameTitle.text = user.name;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
        [cell.userImageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               SDFollowingCell *myCell = (SDFollowingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                               myCell.userImageView.image = image;
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               //
                                           }];
        
        //check for following
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
        
        if ([user.followedBy isEqual:master]) {
            cell.followButton.selected = YES;
        }
        else {
            cell.followButton.selected = NO;
        }
        
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleWhite;
        
        if ([_searchBar.text length] > 0) {
            activityViewStyle = UIActivityIndicatorViewStyleGray;
        }
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_searchActive) {
            [self loadMoreData];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 1)];
    result.backgroundColor = [UIColor clearColor];
    
    return result;
}

#pragma mark - Following actions

- (IBAction)followButtonPressed:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Updating list";
    [self hideKeyboard];
    
    User *user = [self.searchResults objectAtIndex:sender.tag];
    [self.userSet addObject:user.identifier];
    
    if (!sender.selected) {
        //following action
        [SDFollowingService followUserWithIdentifier:user.identifier withCompletionBlock:^{
            
            //update user
            NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
            Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
            user.followedBy = master;
            NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
            [context MR_save];
            [self reloadTableView];
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    }
    else {
        //unfollowing action
        [SDFollowingService unfollowUserWithIdentifier:user.identifier withCompletionBlock:^{
            user.followedBy = nil;
            NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
            [context MR_save];
            [self reloadTableView];
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    }
}

- (void)reloadTableView
{
    if ([_searchBar.text length] > 0) {
        //reload searchresultstableview tu update cell
        for (UITableView *tView in self.view.subviews) {
            if ([[tView class] isSubclassOfClass:[UITableView class]]) {
                [tView reloadData];
                break;
            }
        }
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)reloadView
{
    if ([_searchBar.text length] > 0) {
        [self filterContentForSearchText:_searchBar.text];
    }
    else {
        [self filterContentForSearchText:@""];
    }
}

- (void)hideKeyboard
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

#pragma mark - UISearchDisplayController delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchActive = YES;
    //filter users in local DB
    [self filterContentForSearchText:searchString];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        
        if ((_currentFollowersPage+1)*kMaxItemsPerPage < _totalFollowers ) { //if all users are already downloaded we do not need additional call to webservice
            
            [SDFollowingService getListOfFollowersForUserWithIdentifier:master.identifier withSearchString:searchString withCompletionBlock:^{
                _searchActive = NO;
                //in case later request will finish first, use _searchBar.text
                [self filterContentForSearchText:_searchBar.text];
            } failureBlock:^{
                _searchActive = NO;
                [self reloadTableView];
            }];
        }
    }
    else {
        if ((_currentFollowingPage+1)*kMaxItemsPerPage < _totalFollowings ) { //if all users are already downloaded we do not need additional call to webservice
            
            [SDFollowingService getListOfFollowingsForUserWithIdentifier:master.identifier withSearchString:searchString withCompletionBlock:^{
                _searchActive = NO;
                //in case later request will finish first, use _searchBar.text
                [self filterContentForSearchText:_searchBar.text];
            } failureBlock:^{
                _searchActive = NO;
                [self reloadTableView];
            }];
        }
    }
    
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self reloadView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SDFollowingCell" bundle:nil] forCellReuseIdentifier:@"FollowingCellID"];
}

#pragma mark - did logout

- (void)userDidLogout
{
    self.searchResults = nil;
}

@end
