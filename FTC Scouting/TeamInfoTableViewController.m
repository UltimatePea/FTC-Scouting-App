//
//  TeamInfoTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/12/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "TeamInfoTableViewController.h"
#import "NSURL+Directory.h"
#import "TeamInfoViewerTableViewController.h"

@interface TeamInfoTableViewController ()

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableArray*listOfData, *fileURLs;
@property (strong, nonatomic) NSURL *rootURL;



@end

@implementation TeamInfoTableViewController

- (NSMutableArray *)fileURLs
{
    if (!_fileURLs) {
        _fileURLs = [NSMutableArray array];
    }
    return _fileURLs;
}

- (NSMutableArray *)listOfData
{
    if (!_listOfData) {
        _listOfData  = [NSMutableArray array];
    }
    return _listOfData;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self analyze];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self analyze];
    [self.tableView reloadData];
}

- (void)analyze
{
    self.listOfData = nil;
    self.fileURLs = nil;
    NSURL *directory = [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    directory = [directory URLByAppendingPathComponent:@"teams/"];
    if ([self.fileManager fileExistsAtPath:directory.path]) {
        NSError *dirErr;
        self.rootURL = directory;
        NSArray *urls = [self.fileManager contentsOfDirectoryAtURL:directory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&dirErr];
        if (dirErr) {
//            self.title = @"Directory Read Error";
            [[[UIAlertView alloc] initWithTitle:@"Directory Read Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURL *fileURL = obj;
            if ([fileURL isDirectory]) {
                return ;
            }
            if (![fileURL.pathExtension isEqualToString:@"plist"]){
                return;
            }
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:fileURL];
            if (dictionary) {
                [self.listOfData addObject:dictionary];
                [self.fileURLs addObject:fileURL];
            }
        }];
    }
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
    return [self.listOfData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"team info cell" forIndexPath:indexPath];
    
    NSDictionary *dic = [self.listOfData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", dic[@"Team Number"], dic[@"Team Name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", dic[@"Notes"]];
    UIImage *image;
    if(dic[@"Photo"]){
         image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.rootURL URLByAppendingPathComponent:dic[@"Photo"]]]];
    }
    
    if (image) {
        cell.imageView.image = image;
    } else {
        cell.imageView.image = nil;
    }
    
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"show team info"]) {
        if ([segue.destinationViewController isKindOfClass:[TeamInfoViewerTableViewController class]]) {
            TeamInfoViewerTableViewController *tivtc = segue.destinationViewController;
            tivtc.fileURL = [self.fileURLs objectAtIndex:[self.tableView indexPathForCell:sender].row];
        }
    }
}


@end
