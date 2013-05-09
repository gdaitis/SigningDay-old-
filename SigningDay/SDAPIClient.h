//
//  SDAPIClient.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

extern NSString * const kSDBaseSigningDayURLString;
extern NSString * const kSDAPICLientNoApiKeyNotification;
extern NSString * const kSDOldAPIBaseURLString;
extern NSString * const kSDAPIBaseURLString;

@interface SDAPIClient : AFHTTPClient

+ (SDAPIClient *)sharedClient;
- (void)setRestTokenHeaderWithToken:(NSString *)token;

@end
