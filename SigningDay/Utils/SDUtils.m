//
//  SDUtils.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import "SDUtils.h"
#import "Master.h"
#import "SDFollowingService.h"
#import "SDLoginService.h"

@interface SDUtils()

+ (BOOL)databaseCompatible;

@end

@implementation SDUtils

+ (void)setupCoreDataStack
{
    /*
     if (![self databaseCompatible]) {
     NSLog(@"Database incompatible");
     [MagicalRecord setupAutoMigratingCoreDataStack];
     }
     else {
     
     NSLog(@"Database compatible");
     [MagicalRecord setupCoreDataStack];
     }*/
    BOOL needsLogout = NO;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"buildVersion"] intValue] < [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[NSPersistentStore MR_defaultLocalStoreUrl].path
                                                   error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"buildVersion"];
        needsLogout = YES;
    }
    [MagicalRecord setupCoreDataStack];
    
    if (needsLogout) {
        [SDLoginService logout];
    }
}


#pragma mark - Compatibility checking

+ (BOOL)databaseCompatible
{
    //check if migration is needed
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
    NSURL *storeUrl = [NSPersistentStore MR_defaultLocalStoreUrl];
    
    // Determine if a migration is needed
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                            error:&error];
    NSManagedObjectModel *destinationModel = [persistentStoreCoordinator managedObjectModel];
    BOOL result = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    
    return result;
}



@end
