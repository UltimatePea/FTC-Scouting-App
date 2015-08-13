//
//  FilesTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/19/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "FilesTableViewController.h"
#import "PlistTableViewController.h"
#import "NSURL+Directory.h"
#import "NSDictionary+Indexing.h"
#import "PlistUploader.h"
@interface FilesTableViewController () <PlistUploaderDelegate>

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSMutableDictionary *fullURLs;
@property (strong, nonatomic) PlistUploader *plistUploader;
@property (nonatomic) int numberStartedToUpload, numberUploaded, numberFailed;
@property (strong, nonatomic) UIAlertController *uploadAlert;

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation FilesTableViewController

- (NSUserDefaults *)defaults
{
    if (!_defaults) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
}

- (PlistUploader *)plistUploader
{
    if (!_plistUploader) {
        _plistUploader = [[PlistUploader alloc] init];
        _plistUploader.uploadDelegate = self;
    }
    return _plistUploader;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager   ];
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
   // [self updatePathsAndURLs];
    [self analyze];
    [self.tableView reloadData];
    
    
}
/*
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
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[self.data objectForKeyAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.data allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)] objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *teamMatches = [self.data objectForKeyAtIndex:indexPath.section];
    cell.textLabel.text = [[teamMatches.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)] objectAtIndex:indexPath.row];
    
    return cell;
}




- (void)analyze
{
    NSURL *documentDirectory  =  [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
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
    NSError *error;
    NSArray *contentsRoot = [self.fileManager contentsOfDirectoryAtURL:documentDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if (error) {
//        self.title = @"Document Root Read Error";
        [[[UIAlertView alloc] initWithTitle:@"Document Root Read Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    NSMutableDictionary *structure = [NSMutableDictionary dictionary];
    
    self.fullURLs = [NSMutableDictionary dictionary];
    [contentsRoot enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *dir = obj;
        if (![dir isDirectory]) {
            return;
        }
        NSUInteger indexOfContentsRoots = idx;
        NSString *key = [[dir pathComponents] lastObject];
        NSError *subError;
        NSArray *plists = [self.fileManager contentsOfDirectoryAtURL:dir includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&subError];
        if (subError) {
//            self.title = @"Match files read error";
            [[[UIAlertView alloc] initWithTitle:@"Match files read error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        if ([plists count] == 0) {
            [self.fileManager removeItemAtURL:dir error:nil];
            return;
        }
        
        NSMutableDictionary *subStructures = [NSMutableDictionary dictionary];
        [self.fullURLs setObject:[NSMutableDictionary dictionary] forKey:key];
        [plists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isDirectory] || ![[obj pathExtension] isEqualToString:@"plist"]) {
                return;
            }
            NSString *subKey = [[obj pathComponents] lastObject];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:obj];
            
            [subStructures setObject:dic forKey:subKey];
            [[self.fullURLs objectForKey:key] setObject:obj forKey:subKey];
        }];
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
    
    
    self.data = structure;
    
    [self.tableView reloadData];
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    
    
    return YES;
    
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *key1 = [[self.data.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)] objectAtIndex:indexPath.section];
        NSString *key2 = [[[[self.data objectForKey:key1] allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)] objectAtIndex:indexPath.row];
        NSURL *url = [[self.fullURLs objectForKey:key1] objectForKey:key2];
        // Delete the row from the data source
        if (![url isDirectory]) {
            //delete file
            NSError *error;
            
            [self.fileManager removeItemAtURL:url error:&error];
            if (error) {
//                self.title = @"An Error occurred during file deletion";
                [[[UIAlertView alloc] initWithTitle:@"An Error occurred during file deletion" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            } else {
                //self.title = @"File Deleted";
            }
            [self analyze];
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        } else {
            //delete directory
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Comfirm Delete" message:@"Are you sure to delete the directory and all of its contents?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                NSError *error;
                
                [self.fileManager removeItemAtURL:url error:&error];
                if (error) {
//                    self.title = @"An Error occurred during directory deletion";
                    [[[UIAlertView alloc] initWithTitle:@"An Error occurred during directory deletion" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    return;
                } else {
                    //self.title = @"File Deleted";
                }
                [self analyze];
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
    if ([segue.identifier isEqualToString:@"segue to plist table view controller"]) {
        if ([segue.destinationViewController isKindOfClass:[PlistTableViewController class]]) {
            PlistTableViewController *ptvvc = segue.destinationViewController;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSError *error;
            ptvvc.displayingPlist = [[self.data  objectForKeyAtIndex:indexPath.section] objectForKeyAtIndex:indexPath.row];
            ptvvc.title = ((UITableViewCell *)sender).textLabel.text;
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
}
- (IBAction)shareAll:(id)sender {
#warning COPY CODE
    self.numberFailed = 0;
    self.numberStartedToUpload = 0;
    self.numberUploaded = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i < self.tableView.numberOfSections; i ++) {
        for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j ++) {
            NSDictionary *dic = [[self.data objectForKeyAtIndex:i] objectForKeyAtIndex:j];
            
            if ([defaults objectForKey:[NSString stringWithFormat:@"%@||%@", dic[@"Team Number"], dic[@"Date"]]]) {
                continue;
            }
            if (dic[@"Contributor"]) {
                continue;
            }
            if ([dic[@"Team Number"] intValue] == 0 || [dic[@"Total Score"] intValue] == 0) {
                continue;
            }
            
            self.numberStartedToUpload++;
        }
    }
    if (self.numberStartedToUpload == 0) {
        
        [[[UIAlertView alloc] initWithTitle:@"All Files Have Been Uploaded" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Your Name" message:@"We will record your name as contributor of information." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        if ([defaults objectForKey:@"Contributor"]) {
            textField.text = [defaults objectForKey:@"Contributor"];
        }
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
        NSString *userName =((UITextField *)[[alertController textFields] firstObject]).text;
        [defaults setObject:userName forKey:@"Contributor"];
        
        for (int i = 0; i < self.tableView.numberOfSections; i ++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j ++) {
                NSDictionary *dic = [[self.data objectForKeyAtIndex:i] objectForKeyAtIndex:j];
                
                if ([defaults objectForKey:[NSString stringWithFormat:@"%@||%@", dic[@"Team Number"], dic[@"Date"]]]) {
                    continue;
                }
                
                if (dic[@"Contributor"]) {
                    continue;
                }
                if ([dic[@"Team Number"] intValue] == 0 || [dic[@"Total Score"] intValue] == 0) {
                    continue;
                }
                [self.plistUploader uploadPlist:dic withContributot:userName withDeviceID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
                
                //self.numberStartedToUpload++;
            }
        }
        
        
       
        self.uploadAlert = [UIAlertController alertControllerWithTitle:@"Upload" message:@"Uploading" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.uploadAlert dismissViewControllerAnimated:YES completion:nil];
            self.uploadAlert = nil;
        }];
        [self.uploadAlert addAction:cancel];
        [self presentViewController:self.uploadAlert animated:YES completion:^{
            [self updateUploadAlert];
        }];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)updateUploadAlert
{
    self.uploadAlert.message = [NSString stringWithFormat:@"%d succeeded with %d failed in a total of %d uploads", self.numberUploaded, self.numberFailed, self.numberStartedToUpload];
    if (self.numberStartedToUpload == self.numberUploaded + self.numberFailed) {
        self.uploadAlert.message = [self.uploadAlert.message stringByAppendingString:@"\r\nUpload Succeeded"];
        [[self.uploadAlert actions].firstObject setTitle:@"OK"];
    }
}

- (void)uploader:(PlistUploader *)uploader informUserWithString:(NSString *)str
{
    self.numberUploaded++;
    [self updateUploadAlert];
}

- (void)uploader:(PlistUploader *)uploader failedWithString:(NSString *)str
{
    self.numberFailed++;
    [self updateUploadAlert];
}
//
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if ([sender isKindOfClass:[UITableViewCell class]]) {
//        if ([identifier isEqualToString:@"segue to plist table view controller"]) {
//            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//            NSURL *url = [self.fullurls objectAtIndex:indexPath.row];
//            BOOL result = ![url isDirectory];
//            return result;
//        }
//    }
//    
//    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
//}

@end
