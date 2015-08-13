//
//  PlistUploader.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/11/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "PlistUploader.h"

@interface PlistUploader ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableDictionary *operationQueue;

@end

@implementation PlistUploader

- (NSMutableDictionary *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [NSMutableDictionary dictionary];
    }
    return _operationQueue;
}

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}


- (void)uploadPlist:(NSDictionary *)plist withContributot:(NSString *)contributor withDeviceID:(NSString *)deviceID
{
    NSDictionary *detail = plist[@"Detailed Score"];
    
    NSString *post = [NSString stringWithFormat:@"total_score=%@&team_name=%@&team_number=%@&notes=%@&auto_did_not_move=%@&driver_controlled_did_not_move=%@&match_info=%@&120cm_score=%@&30cm_score=%@&60cm_score=%@&90cm_score=%@&number_on_ramp=%@&number_in_parking_area=%@&descend_ramp=%@&score_center_goal=%@&score_rolling_goal=%@&drag_rolling_goal_into_parking_area=%@&hit_kick_stand=%@&contributor=%@&time_created=%@&device_id=%@",
                      [self percentEscapeString:plist[@"Total Score"]],
                      [self percentEscapeString:plist[@"Team Name"]],
                      [self percentEscapeString:plist[@"Team Number"]],
                      [self percentEscapeString:plist[@"Notes"]],
                      [self percentEscapeString:plist[@"Auto Didn't Move"]],
                      [self percentEscapeString:plist[@"Driver Controlled Didn't Move"]],
                      [self percentEscapeString:plist[@"Match Info"]],
                      [self percentEscapeString:detail[@"120cm Score (6 points per cm)"]],
                      [self percentEscapeString:detail[@"30cm Score (1 points per cm)"]],
                      [self percentEscapeString:detail[@"60cm Score (2 points per cm)"]],
                      [self percentEscapeString:detail[@"90cm Score (3 points per cm)"]],
                      [self percentEscapeString:detail[@"Number on Ramp (30 points per item)"]],
                      [self percentEscapeString:detail[@"Number in Parking Area (10 points per item)"]],
                      [self percentEscapeString:detail[@"Descend Ramp (20 points)"]],
                      [self percentEscapeString:detail[@"Score Center Goal (60 points)"]],
                      [self percentEscapeString:detail[@"Score Rolling Goal (30 points)"]],
                      [self percentEscapeString:detail[@"Drag Rolling Goal into Parking Area (20 points)"]],
                      [self percentEscapeString:detail[@"Hit Kick Stand (30 points)"]],
                      [self percentEscapeString:contributor],
                      [self percentEscapeString:plist[@"Date"]],
                      [self percentEscapeString:deviceID]
                      ];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://qubic-lab.com/FTC%20Scouting%20Server/upload_match.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *connec = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connec) {
        NSLog(@"Connected successfully");
        [self.operationQueue setObject:connec forKey:plist];
        
    } else {
        NSLog(@"Connection Failed");
    }
    
}



- (NSString *)percentEscapeString:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        return string;
    }
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@ URL CONNECTION FAILED", error);
    [self.uploadDelegate uploader:self failedWithString:@"Unable to upload. Please try again later."];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if ([str containsString:@"error"]||[str containsString:@"Error"]) {
        [self.uploadDelegate uploader:self failedWithString:str];
        return;
    }
    
    __block NSDictionary *plist;
    [self.operationQueue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqual:connection]) {
            plist = key;
        }
    }];
    [self.userDefaults setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@||%@", plist[@"Team Number"], plist[@"Date"]]];
    if ([self.userDefaults objectForKey:@"Credit"]) {
        [self.userDefaults setObject:[NSNumber numberWithInt:[[self.userDefaults objectForKey:@"Credit"] intValue] + 10] forKey:@"Credit"];
    } else {
        [self.userDefaults setObject:[NSNumber numberWithInt:10] forKey:@"Credit"];
    }
    
    [self.uploadDelegate uploader:self informUserWithString:str];
}


@end
