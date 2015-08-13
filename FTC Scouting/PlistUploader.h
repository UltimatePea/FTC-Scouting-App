//
//  PlistUploader.h
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/11/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlistUploader;

@protocol PlistUploaderDelegate <NSObject>

- (void)uploader:(PlistUploader *)uploader informUserWithString:(NSString *)str;
- (void)uploader:(PlistUploader *)uploader failedWithString:(NSString *)str;

@end

@interface PlistUploader : NSObject <NSURLConnectionDataDelegate>


- (void)uploadPlist:(NSDictionary *)plist withContributot:(NSString *)contributor withDeviceID:(NSString *)deviceID;

@property (weak, nonatomic) id<PlistUploaderDelegate> uploadDelegate;

@end
