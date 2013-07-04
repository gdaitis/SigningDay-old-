//
//  ImageData.h
//  SigningDay
//
//  Created by Lukas Kekys on 7/2/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageData : NSManagedObject

@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * urlString;

@end
