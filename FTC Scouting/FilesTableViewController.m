//
//  FilesTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/19/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "FilesTableViewController.h"
#import "PlistViewerViewController.h"

@interface FilesTableViewController ()

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSArray *paths, *fullurls;

@end

@implementation FilesTableViewController

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager   ];
    }
    return _fileManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSURL *documentsDirectory = [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSError *error;
    self.paths = [self.fileManager subpathsOfDirectoryAtPath:[documentsDirectory path] error:&error];
    if (error) {
        self.title = @"Path Read Error";
    }
    NSMutableArray *fullurls = [NSMutableArray array];
    [self.paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [fullurls addObject:[documentsDirectory URLByAppendingPathComponent:obj]];
    }];
    self.fullurls = fullurls;
    [self.tableView reloadData];
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
    return [self.paths count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.paths objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
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



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue to plist view controller"]) {
        if ([segue.destinationViewController isKindOfClass:[PlistViewerViewController class]]) {
            PlistViewerViewController *pvvc = segue.destinationViewController;
            NSError *error;
            pvvc.content = [NSDictionary dictionaryWithContentsOfURL:[self.fullurls objectAtIndex:[self.tableView indexPathForCell:sender].row]];
            pvvc.title = [self.paths objectAtIndex:[self.tableView indexPathForCell:sender].row];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
}


@end
