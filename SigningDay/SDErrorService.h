//
//  SDErrorService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/27/12.
//
//

#import <Foundation/Foundation.h>

@interface SDErrorService : NSObject

+ (void)handleError:(NSError *)error;
+ (void)handleFacebookError;

@end
