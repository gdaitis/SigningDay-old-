//
//  SDAPIClient.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "STKeychain.h"

@interface SDAPIClient ()

- (id)initWithBaseURL:(NSURL *)url;

@end

NSString * const kSDBaseSigningDayURLString = @"https://www.signingday.com/";
NSString * const kSDAPIBaseURLString = @"https://www.signingday.com/api.ashx/v2/";
NSString * const kSDOldAPIBaseURLString = @"https://www.signingday.com/api/";
NSString * const kSDAPICLientNoApiKeyNotification = @"SDAPICLientNoApiKeyNotificationName";

@implementation SDAPIClient

+ (SDAPIClient *)sharedClient
{
    static SDAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SDAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kSDAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url 
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *apiKey = [STKeychain getPasswordForUsername:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]
                                           andServiceName:@"SigningDay"
                                                    error:nil];
    if (!apiKey) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSDAPICLientNoApiKeyNotification object:nil];
    } else {
        [self setRestTokenHeaderWithToken:apiKey];
    }
    
    return self;
}

- (void)setRestTokenHeaderWithToken:(NSString *)token 
{
    [self setDefaultHeader:@"Rest-User-Token" value:[NSString stringWithFormat:@"%@", token]];
}

@end
