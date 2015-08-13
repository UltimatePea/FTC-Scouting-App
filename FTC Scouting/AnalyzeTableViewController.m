//
//  AnalyzeTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/21/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "AnalyzeTableViewController.h"
#import "NSURL+Directory.h"
#import "TeamDetailViewController.h"
#import "PlistDownloader.h"


@interface AnalyzeTableViewController () <PlistDownloaderDelegate>

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSDictionary *data, *evaluation;
@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) PlistDownloader *downloader;
@property (strong, nonatomic) UIAlertController *alertController;


@end

@implementation AnalyzeTableViewController

- (PlistDownloader *)downloader
{
    if (!_downloader) {
        _downloader = [[PlistDownloader alloc] init];
        _downloader.delegate = self;
    }
    return _downloader;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}
//the property index is the unit circle cross sections [0...5]
- (NSArray *)keysForPolygonProperty:(int)propertyIndex
{
    
    switch (propertyIndex) {
        case 0:
            return @[@"60cm Score (2 points per cm)"];
            break;
        case 1:
            return @[@"Score Center Goal (60 points)", @"Hit Kick Stand (30 points)"];
            break;
        case 2:
            return @[@"120cm Score (6 points per cm)"];
            break;
        case 3:
            return @[@"Descend Ramp (20 points)",
                     @"Rolling Goal Score (30 points)",
                     @"Drag Rolling Goal into Parking Area (20 points)"];
            break;
        case 4:
            return @[@"Number on Ramp (30 points per item)"];
            break;
        case 5:
            return @[@"90cm Score (3 points per cm)"];
            break;
        default:
            NSLog(@"Unrecognized category");
            break;
    }
    return nil;
}

- (int)totalMaximumEstimatedScoreForPolygonProperty:(int)propertyIndex
{
    switch (propertyIndex) {
        case 0:
            return 30 * 2;
            break;
        case 1:
            return 90;
            break;
        case 2:
            return 28 * 6;
            break;
        case 3:
            return 70;
            break;
        case 4:
            return 120;
            break;
        case 5:
            return 60 * 3;
            break;
            
        default:
            break;
    }
    return -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.downloader downloadAllData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)downloadData:(id)sender
{
   
    self.alertController = [UIAlertController alertControllerWithTitle:@"Fetching Data From Server" message:@"Fetching" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.alertController dismissViewControllerAnimated:YES completion:nil];
        self.alertController = nil;
        
    }];
    [self.alertController addAction:cancel];
    [self presentViewController:self.alertController animated:YES completion:^{
         [self.downloader downloadAllData];
    }];
}

- (void)downloader:(PlistDownloader *)downloader didFailToReadReceivedData:(NSData *)data
{
    self.alertController.message = @"Failed to load data from server!";
//    [[self.alertController.actions firstObject] setTitle:@"OK"];
    
}

- (void)downloader:(PlistDownloader *)downloader didFailToLoadDataWithError:(NSError *)error
{
    self.alertController.message = @"Check your Internet connection. Try again later";
//    [[self.alertController.actions firstObject] setTitle:@"OK"];
}

- (void)downloader:(PlistDownloader *)downloader didLoadData:(NSArray *)allGroups
{
    NSURL *documentDirectory  =  [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSError *error;
    documentDirectory = [documentDirectory URLByAppendingPathComponent:@"matches/"];
    if (![self.fileManager fileExistsAtPath:[documentDirectory path]]) {
        NSError *mkdirErr;
        [self.fileManager createDirectoryAtPath:[documentDirectory path] withIntermediateDirectories:YES attributes:nil error:&mkdirErr];
        if (mkdirErr) {
//            self.title = @"Directory creation error";
            
            [[[UIAlertView alloc] initWithTitle:@"Directory creation error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    [allGroups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *matchResult = obj;
        NSString *teamNumber = matchResult[@"Team Number"];
        NSString *date = matchResult[@"Date"];
        NSURL *dirURL = [documentDirectory URLByAppendingPathComponent:[NSString stringWithFormat: @"%@/", teamNumber]];
        if (![self.fileManager fileExistsAtPath:dirURL.path]) {
            NSError *teamNumDir;
            [self.fileManager createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:&teamNumDir];
            if (teamNumDir) {
//                self.title = @"Directory of Team Number Creation Error";
                [[[UIAlertView alloc] initWithTitle:@"Directory of Team Number Creation Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
        }
        NSURL *fileURL = [dirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", date]];
        if ([self.fileManager fileExistsAtPath:fileURL.path]) {
            
        } else {
            if ([self.fileManager createFileAtPath:fileURL.path contents:[NSKeyedArchiver archivedDataWithRootObject:matchResult] attributes:nil]) {
                [matchResult writeToURL:fileURL atomically:YES];
            } else {
//                self.title = @"Cannot save data";
                [[[UIAlertView alloc] initWithTitle:@"Cannot save data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
            
        }
    }];
    self.alertController.message = @"Fetched Successfully. You can check the data on match history and on this page.";
//    [[self.alertController.actions firstObject] setTitle:@"OK"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.data  count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [[self.data allKeys] objectAtIndex:section];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"analyze table view cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.keys objectAtIndex:indexPath.row];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IB 
#warning this code is copied BEGIN
- (IBAction)analyze:(id)sender
{
    NSURL *documentDirectory  =  [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSError *error;
    documentDirectory = [documentDirectory URLByAppendingPathComponent:@"matches/"];
    if (![self.fileManager fileExistsAtPath:[documentDirectory path] isDirectory:NULL]) {
        NSError *mkdirErr;
        [self.fileManager createDirectoryAtPath:[documentDirectory path] withIntermediateDirectories:YES attributes:nil error:&mkdirErr];
        if (mkdirErr) {
//            self.title = @"Directory creation error";
            [[[UIAlertView alloc] initWithTitle:@"Directory creation error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    NSArray *contentsRoot = [self.fileManager contentsOfDirectoryAtURL:documentDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if (error) {
//        self.title = @"Document Root Read Error";
        [[[UIAlertView alloc] initWithTitle:@"Document Root Read Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    NSMutableDictionary *structure = [NSMutableDictionary dictionary];
    
    
    [contentsRoot enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *dir = obj;
        if (![dir isDirectory]) {
            return;
        }
        
        NSString *key = [[dir pathComponents] lastObject];
        NSError *subError;
        NSArray *plists = [self.fileManager contentsOfDirectoryAtURL:dir includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&subError];
        if (subError) {
//            self.title = @"Match files read error";
            [[[UIAlertView alloc] initWithTitle:@"Match files read error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        
        NSMutableDictionary *subStructures = [NSMutableDictionary dictionary];
        [plists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isDirectory] || ![[obj pathExtension] isEqualToString:@"plist"]) {
                return;
            }
            
            NSString *key = [[obj pathComponents] lastObject];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:obj];
            
            
            NSDictionary *aMatch = dic;
            if ([[aMatch objectForKey:@"总分"] intValue] == 0 && [[aMatch objectForKey:@"Total Score"] intValue] == 0) {
                //eligibleCount--;
                return;
            }
            
            
            [subStructures setObject:dic forKey:key];
            
        }];
        if ([subStructures count] == 0) {
            return;
        }
        [structure setObject:subStructures forKey:key];
        
    }];
    
    /*
     
     structure : NSDictionary 
            key: team name
            value: substructure
     
     subStructure : NSDictionary
            key : timeOfMatch
            contains: team score information
     
     teamScoreInformation : NSDictionary
            intepreted in Plist Table View Controller, see Sample.plist
     
     
     */
    
    //sort
    
    NSArray *keys = [structure.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int int1 = [obj1 intValue], int2 = [obj2 intValue];
        if (int1 == int2) {
            return NSOrderedSame;
        } else if (int1 > int2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    self.keys = keys;
    
    self.data = structure;
//    [self analyzeLoadedData];
    [self.tableView reloadData];
    
}
#warning this code is copied END

//- (void)analyzeLoadedData
//{
//    NSMutableDictionary * evaluation = [NSMutableDictionary dictionary];
//    
//    [self.data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        NSMutableDictionary *subEvaluation = [NSMutableDictionary dictionary];
//        
//        NSDictionary *teamMatchesInfo = obj;
//        
//        
//        
//        
//        
//        
//        [teamMatchesInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            NSDictionary *teamScores = [obj objectForKey:@"详细分数"];
//            
//        
//        
//        
//        }];
//        
//        
//        
//        
//        
//        [evaluation setObject:subEvaluation forKey:key];
//    }];
//    self.evaluation = evaluation;
//    
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue to show team detail"]) {
        if ([segue.destinationViewController isKindOfClass:[TeamDetailViewController class]]) {
            TeamDetailViewController *tdvc = segue.destinationViewController;
            UITableViewCell *cell = sender;
            [self setValuesForTeamKey:cell.textLabel.text forVC:tdvc];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)setValuesForTeamKey:(NSString *)key forVC:(TeamDetailViewController *)tdvc
{
    NSDictionary *allMatches = [self.data objectForKey:key];
    NSMutableDictionary *scoreSums = [NSMutableDictionary dictionary];
    
   __block NSUInteger eligibleCount = [allMatches count];
    //sum
    [allMatches enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *aMatch = obj;
        if ([[aMatch objectForKey:@"总分"] intValue] == 0 && [[aMatch objectForKey:@"Total Score"] intValue] == 0) {
            eligibleCount--;
            return;
        }
        
        NSDictionary *matchDetail = [aMatch objectForKey:@"详细分数"];
        if (!matchDetail) {
            matchDetail = [aMatch objectForKey:@"Detailed Score"];
        }
        [matchDetail enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSNumber *sumScore = [NSNumber numberWithInt:[[scoreSums objectForKey:key] intValue] + [obj intValue]];
            [scoreSums setObject:sumScore forKey:key];
        }];
    }];
    
    //get the mean data
    [scoreSums enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [scoreSums setObject:[NSNumber numberWithFloat:(float)[obj intValue] / (float)eligibleCount] forKey:key];
    }];
    
    NSMutableArray *polygonValues = [NSMutableArray array];
    
    for (int i = 0; i < 6; i ++) {
        NSArray *desiredKeys = [self keysForPolygonProperty:i];
        __block float localSum = 0.0;
        [desiredKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            localSum += [[scoreSums objectForKey:obj] floatValue];
        }];
        [polygonValues addObject:[NSNumber numberWithFloat:localSum / (float) [self totalMaximumEstimatedScoreForPolygonProperty:i]]];
    }
    tdvc.hexagonValues = polygonValues;
    tdvc.title = key;
    if (eligibleCount == 0) {
        tdvc.title = [NSString stringWithFormat:@"%@：%@", tdvc.title, @"There is not enough data available."];
    }
}

@end
