//
//  PlistDownloader.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/13/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "PlistDownloader.h"

@interface PlistDownloader () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSMutableData *data;

@end

@implementation PlistDownloader

- (NSMutableData *)data
{
    if (!_data) {
        _data = [NSMutableData data];
    }
    return _data;
}

- (void)downloadAllData
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://qubic-lab.com/FTC%20Scouting%20Server/fetch_all_data.php"]];
    NSURLConnection *connec = [NSURLConnection connectionWithRequest:request delegate:self];
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonReadErr;
    NSArray *serial = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonReadErr];
    if (jsonReadErr) {
        [self.delegate downloader:self didFailToReadReceivedData:self.data];
        return;
    }
    if ([serial isKindOfClass:[NSArray class]]) {
        [self.delegate downloader:self didLoadData:[self analyzedServerData:serial]];
    } else {
        [self.delegate downloader:self didFailToReadReceivedData:self.data];
    }
    self.data = nil;
}

- (NSArray *)analyzedServerData:(NSArray *)data
{
    NSMutableArray *analyzedData = [NSMutableArray array];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *matchData = obj;
        NSMutableDictionary *convertedResult = [NSMutableDictionary dictionary];
        [[self generalTitle] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [convertedResult setObject:[matchData objectForKey:key] forKey:obj];
        }];
        NSMutableDictionary *detailedScore = [NSMutableDictionary dictionary];
        [convertedResult setObject:detailedScore forKey:@"Detailed Score"];
        [[self detailTitle] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [detailedScore setObject:[matchData objectForKey:key] forKey:obj];
        }];
        
        
        
        [analyzedData addObject:convertedResult];
    }];
    return analyzedData;
    
}

- (NSDictionary *)detailTitle
{
    return  @{@"120cm_score" :@"120cm Score (6 points per cm)",
              @"30cm_score": @"30cm Score (1 points per cm)",
              @"60cm_score":@"60cm Score (2 points per cm)",
              @"90cm_score" : @"90cm Score (3 points per cm)",
              
              @"descend_ramp" : @"Descend Ramp (20 points)",
              
              @"drag_rolling_goal_into_parking_area" : @"Drag Rolling Goal into Parking Area (20 points)",
              
              @"hit_kick_stand" :  @"Hit Kick Stand (30 points)",
              
              
              @"number_in_parking_area" :  @"Number in Parking Area (10 points per item)",
              @"number_on_ramp" : @"Number on Ramp (30 points per item)",
              @"score_center_goal" : @"Score Center Goal (60 points)",
              @"score_rolling_goal" : @"Score Rolling Goal (30 points)"
              
             };
}

- (NSDictionary *)generalTitle
{
    return @{
        @"contributor" : @"Contributor",
        //@"device_id" : @"Device ID",
        //@"id" : @"ID",
        @"match_info" : @"Match Info",
        @"notes" :  @"Notes",
        @"team_name" : @"Team Name",
        @"team_number" : @"Team Number",
        //@"time_created" : @"Time Created",
        @"time_uploaded" : @"Date",
        @"total_score" : @"Total Score",
        @"auto_did_not_move" : @"Auto Didn't Move",
        @"driver_controlled_did_not_move" : @"Driver Controlled Didn't Move",
    };
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate downloader:self didFailToLoadDataWithError:error];
    NSLog(@"Error");
}

@end
