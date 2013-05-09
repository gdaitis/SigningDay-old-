//
//  ImageData.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageData : NSManagedObject

@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * urlString;

@end
