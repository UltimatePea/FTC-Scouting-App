//
//  TeamInfoViewerTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/12/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "TeamInfoViewerTableViewController.h"
#import "NewTeamInfoTableViewController.h"

@interface TeamInfoViewerTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *teamNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *teamNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *notesCell;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong ,nonatomic) NSURL *photoURL;

@end

@implementation TeamInfoViewerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:self.fileURL];
    self.teamNameCell.textLabel.text = dic[@"Team Name"];
    self.teamNumberCell.textLabel.text = dic[@"Team Number"];
    self.notesCell.textLabel.text = dic[@"Notes"];
    if (dic[@"Photo"]) {
        NSURL *photoURL = [[self.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:dic[@"Photo"]];
        self.photoURL = photoURL;
        self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
    } else {
        self.photoURL = nil;
    }
}
- (IBAction)delete:(id)sender {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Are you sure to delete this record?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [ac dismissViewControllerAnimated:YES completion:nil];
        NSError *fileDll, *photoDll;
        [[NSFileManager defaultManager] removeItemAtURL:self.fileURL error:&fileDll];
        if (self.photoURL) {
            [[NSFileManager defaultManager] removeItemAtURL:self.photoURL error:&photoDll];
        }
        if (fileDll||photoDll) {
            //        self.title = @"Delete Error";
            [[[UIAlertView alloc] initWithTitle:@"Delete Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
            
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [ac dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [ac addAction:ok];
    [ac addAction:cancel];
    [self presentViewController:ac animated:YES completion:nil];
    
    
}

- (IBAction)edit:(id)sender {
    NewTeamInfoTableViewController *ntitvc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewTeamInfoTableViewController"];
    ntitvc.isForEditing = YES;
    ntitvc.fileURL = self.fileURL;
    [self.navigationController pushViewController:ntitvc animated:YES];
    
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
