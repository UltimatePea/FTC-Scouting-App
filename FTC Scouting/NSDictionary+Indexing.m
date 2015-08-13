//
//  NSDictionary+Indexing.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/21/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "NSDictionary+Indexing.h"

@implementation NSDictionary (Indexing)

- (id)objectForKeyAtIndex:(NSUInteger)index
{
    return [self objectForKey:[[self.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)] objectAtIndex:index]];
}

@end
