//
//  PlistDownloader.h
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/13/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PlistDownloader;

@protocol PlistDownloaderDelegate <NSObject>

- (void)downloader:(PlistDownloader *)downloader didFailToReadReceivedData:(NSData *)data;
- (void)downloader:(PlistDownloader *)downloader didFailToLoadDataWithError:(NSError *)error;
- (void)downloader:(PlistDownloader *)downloader didLoadData:(NSArray *)allGroups;

@end

@interface PlistDownloader : NSObject

- (void)downloadAllData;
@property (weak, nonatomic) id<PlistDownloaderDelegate> delegate;

@end
