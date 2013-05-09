//
//  SDImageService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDImageService : NSObject

+ (SDImageService *)sharedService;
- (void)getImageWithURLString:(NSString *)urlString success:(void (^)(UIImage *image))successBlock;

@end
