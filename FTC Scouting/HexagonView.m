//
//  HexagonView.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/21/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "HexagonView.h"

@implementation HexagonView



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    
    //draw polygon
    for (int i = 0; i < 5; i ++) {
        NSNumber *number = [NSNumber numberWithFloat:(i+1) * 0.2];
        NSMutableArray *valuesArray = [NSMutableArray array];
        for (int j = 0; j < 6; j ++) {
            [valuesArray addObject:[number copy]];
        }
        [self drawBezierPathWithValues:valuesArray inRect:rect withColor:[UIColor lightGrayColor]];
    }
    
    //draw path
    [self drawBezierPathWithValues:[self adjustedValues:self.values] inRect:rect withColor:[UIColor colorWithRed:255.0f/255.0f green:76.0f/255.0f blue:33.0f/255.0f alpha:1.0]];
    
    
    
}

- (NSArray *)adjustedValues:(NSArray *)values
{
    NSMutableArray *result = [NSMutableArray array];
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *number = obj;
        [result addObject:[NSNumber numberWithFloat:  0.8 * [number floatValue] +0.2]];
    }];
    return result;
}

- (void)drawBezierPathWithValues:(NSArray *)values inRect:(CGRect)rect withColor:(UIColor *)color
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint centerPoint = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    CGFloat fullLength = (rect.size.width / 4 * sqrt(3) < rect.size.height / 2)?rect.size.width / 2 :rect.size.height / 2;
    
    CGFloat lengthOne = [[values firstObject] floatValue] * fullLength;
    [path moveToPoint:CGPointMake(centerPoint.x + lengthOne, centerPoint.y)];
    
    
    
    for (int i = 1; i < 6; i ++) {
        CGFloat actualLength = [[values objectAtIndex:i] floatValue];
        CGFloat angle = M_PI / 3 * i;
        CGFloat dx = cos(angle) * actualLength * fullLength;
        CGFloat dy = - sin(angle) * actualLength * fullLength;
        [path addLineToPoint:CGPointMake(centerPoint.x + dx, centerPoint.y + dy)];
        
    }
    
    [path closePath];
    
    [color setStroke];
    path.lineWidth = centerPoint.x / 20;
    [path stroke];
}


@end
