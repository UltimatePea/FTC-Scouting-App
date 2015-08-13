//
//  NewTeamInfoTableViewController.h
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/12/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTeamInfoTableViewController : UITableViewController

@property (nonatomic) BOOL isForEditing;
@property (strong, nonatomic) NSURL *fileURL;

@end
