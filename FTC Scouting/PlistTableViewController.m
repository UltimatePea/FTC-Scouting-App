//
//  PlistTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/20/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "PlistTableViewController.h"
#import "PlistUploader.h"

@interface PlistTableViewController () <PlistUploaderDelegate>

@property (strong, nonatomic) NSMutableArray *firstSectionKeys, *firstSectionValues, *otherSections;
@property (strong, nonatomic) PlistUploader *plistUploader;
@property (strong, nonatomic) UIAlertController *alertController;

@end

@implementation PlistTableViewController



- (PlistUploader *)plistUploader
{
    if (!_plistUploader) {
        _plistUploader = [[PlistUploader alloc] init];
        _plistUploader.uploadDelegate = self;
    }
    return _plistUploader;
}

- (NSMutableArray *)firstSectionKeys
{
    if (!_firstSectionKeys) {
        _firstSectionKeys = [NSMutableArray array];
    }
    return _firstSectionKeys;
}

- (NSMutableArray *)firstSectionValues
{
    if (!_firstSectionValues) {
        _firstSectionValues = [NSMutableArray array];
    }
    return _firstSectionValues;
}

- (NSMutableArray *)otherSections
{
    if (!_otherSections) {
        _otherSections = [NSMutableArray array];
    }
    return _otherSections;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSDictionary *plist = self.displayingPlist;
    __block int numberOfSections = 1, numberOfRowsInFirstSection = 0;
    [plist enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]||[obj isKindOfClass:[NSDictionary class]]) {
            numberOfSections++;
            [self.otherSections addObject:obj];
        } else {
            numberOfRowsInFirstSection ++;
            [self.firstSectionKeys addObject:key];
            [self.firstSectionValues addObject:obj];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.otherSections count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.firstSectionValues count];
    } else {
        id arrayOrDic = [self.otherSections objectAtIndex:section-1];
        return [arrayOrDic count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plist entries" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.firstSectionKeys objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.firstSectionValues objectAtIndex:indexPath.row]];
    } else {
        id arrayOrDic = [self.otherSections objectAtIndex:indexPath.section - 1];
        if ([arrayOrDic isKindOfClass:[NSDictionary class]]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[arrayOrDic allKeys] objectAtIndex:indexPath.row]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [arrayOrDic objectForKey:cell.detailTextLabel.text]];
        }
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:cell.detailTextLabel.text message:cell.textLabel.text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [ac addAction:action];
    [self presentViewController:ac animated:YES completion:nil];
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
- (IBAction)share:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:[NSString stringWithFormat:@"%@||%@", self.displayingPlist[@"Team Number"], self.displayingPlist[@"Date"]]]) {
        [[[UIAlertView alloc] initWithTitle:@"File Already Uploaded" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    if (self.displayingPlist[@"Contributor"]) {
        [[[UIAlertView alloc] initWithTitle:@"File downloaded from server is already shared." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    if ([self.displayingPlist[@"Team Number"] intValue] == 0 || [self.displayingPlist[@"Total Score"] intValue] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"It does not seem to be a good result." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
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
        [self.plistUploader uploadPlist:self.displayingPlist withContributot:userName withDeviceID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
        self.alertController = [UIAlertController alertControllerWithTitle:@"Upload" message:@"Uploading" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.alertController dismissViewControllerAnimated:YES completion:nil];
            self.alertController = nil;
        }];
        [self.alertController addAction:cancel];
        [self presentViewController:self.alertController animated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)uploader:(PlistUploader *)uploader informUserWithString:(NSString *)str
{
    self.alertController.message = str;
    [[[self.alertController actions] firstObject] setTitle:@"OK"];
}

- (void)uploader:(PlistUploader *)uploader failedWithString:(NSString *)str
{
    self.alertController.message = str;
    [[[self.alertController actions] firstObject] setTitle:@"OK"];
}

@end
