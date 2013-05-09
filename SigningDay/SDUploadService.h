//
//  SDUploadService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/6/12.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kSDLogoURLString;

@interface SDUploadService : NSObject

+ (void)uploadPhotoImage:(UIImage *)image
               withTitle:(NSString *)title
             description:(NSString *)description
                    tags:(NSString *)tags
         facebookSharing:(BOOL)facebookSharing
          twitterSharing:(BOOL)twitterSharing
         completionBlock:(void (^)(void))completionBlock;

+ (void)uploadVideoWithURL:(NSURL *)URL
                 withTitle:(NSString *)title
               description:(NSString *)description
                      tags:(NSString *)tags
           facebookSharing:(BOOL)facebookSharing
            twitterSharing:(BOOL)twitterSharing
           completionBlock:(void (^)(void))completionBlock;

@end
