//
//  NSURL+Directory.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/21/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "NSURL+Directory.h"

@implementation NSURL (Directory)

- (BOOL)isDirectory
{
    NSNumber *isDirectory;
    
    // this method allows us to get more information about an URL.
    // We're passing NSURLIsDirectoryKey as key because that's the info we want to know.
    // Also, we pass a reference to isDirectory variable, so it can be modified to have the return value
    BOOL success = [self getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    
    // If we could read the information and it's indeed a directory
    if (success && [isDirectory boolValue]) {
        
        return YES;
    } else {
        
        return NO;
    }
}


@end
