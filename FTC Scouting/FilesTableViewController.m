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
    [self updatePathsAndURLs];
    [self.tableView reloadData];
}

- (void)updatePathsAndURLs
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



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    
    
    return YES;
    
}

- (BOOL)isURLaDirectory:(NSURL *)url
{
    NSNumber *isDirectory;
    
    // this method allows us to get more information about an URL.
    // We're passing NSURLIsDirectoryKey as key because that's the info we want to know.
    // Also, we pass a reference to isDirectory variable, so it can be modified to have the return value
    BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    
    // If we could read the information and it's indeed a directory
    if (success && [isDirectory boolValue]) {
        NSLog(@"Congratulations, it's a directory!");
        return YES;
    } else {
        NSLog(@"It seems it's just a file.");
        return NO;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *url = [self.fullurls objectAtIndex:indexPath.row];
        // Delete the row from the data source
        if (![self isURLaDirectory:url]) {
            //delete file
            NSError *error;
            
            [self.fileManager removeItemAtURL:url error:&error];
            if (error) {
                self.title = @"An Error occurred during file deletion";
            } else {
                //self.title = @"File Deleted";
            }
            [self updatePathsAndURLs];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            //delete directory
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Comfirm Delete" message:@"Are you sure to delete the directory and all of its contents?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                NSError *error;
                
                [self.fileManager removeItemAtURL:url error:&error];
                if (error) {
                    self.title = @"An Error occurred during directory deletion";
                } else {
                    //self.title = @"File Deleted";
                }
                [self updatePathsAndURLs];
                [self.tableView reloadData];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            [ac addAction:ok];
            [ac addAction:cancel];
            [self presentViewController:ac animated:YES completion:nil];
        }
       
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}



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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        if ([identifier isEqualToString:@"segue to plist view controller"]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSURL *url = [self.fullurls objectAtIndex:indexPath.row];
            BOOL result = ![self isURLaDirectory:url];
            return result;
        }
    }
    
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

@end
