//
//  SDErrorService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/27/12.
//
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;

@interface SDErrorService : NSObject

+ (void)handleError:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation;
+ (void)handleFacebookError;

@end
