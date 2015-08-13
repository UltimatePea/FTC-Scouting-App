//
//  RootViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/14/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

- (NSUInteger)supportedInterfaceOrientations
{
    if (([[UIDevice currentDevice].model isEqualToString:@"iPhone"]||[[UIDevice currentDevice].model isEqualToString:@"iPod touch"])) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return [super supportedInterfaceOrientations];
    }
}

@end
