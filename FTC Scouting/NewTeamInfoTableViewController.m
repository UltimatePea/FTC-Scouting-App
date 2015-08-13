//
//  NewTeamInfoTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/12/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "NewTeamInfoTableViewController.h"
#import "LandscapePickerController.h"
@import AssetsLibrary;
@import AVFoundation;

@interface NewTeamInfoTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *teamNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *teamNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *notesTextField;
@property (strong, nonatomic) NSURL *photoURL;

@end

@implementation NewTeamInfoTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teamNameTextField.delegate = self;
    self.teamNameTextField.delegate = self;
    self.notesTextField.delegate = self;
    
    if (self.isForEditing) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:self.fileURL];
        self.teamNameTextField.text = dic[@"Team Name"];
        self.teamNumberTextField.text = dic[@"Team Number"];
        self.notesTextField.text = dic[@"Notes"];
        if (dic[@"Photo"]) {
            NSURL *photoURL = [[self.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:dic[@"Photo"]];
            self.photoURL = photoURL;
            self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
        }
    }
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Please go to Settings->Privacy to change the permission" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show ];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    LandscapePickerController *picker = [[LandscapePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (IBAction)selectPhoto:(UIButton *)sender {
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Please go to Settings->Privacy to change the permission" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show ];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't access photo library" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}



#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
//    self.photoURL = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)save:(id)sender {
    
    if ([self.teamNumberTextField.text isEqualToString: @""]) {
        [[[UIAlertView alloc] initWithTitle:@"Please enter a valid team number." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *directory = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    directory = [directory URLByAppendingPathComponent:@"teams/"];
    if (![manager fileExistsAtPath:[directory path]]) {
        NSError *mkdirErr;
        [manager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:&mkdirErr];
        if (mkdirErr) {
//            self.title = @"Directory creation error";
            [[[UIAlertView alloc] initWithTitle:@"Directory creation error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.teamNameTextField.text forKeyedSubscript:@"Team Name"];
    [dic setObject:self.teamNumberTextField.text forKeyedSubscript:@"Team Number"];
    [dic setObject:self.notesTextField.text forKeyedSubscript:@"Notes"];
    NSURL *imageURL;
    NSURL *fileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",dic[@"Team Number"]]];
    if (self.imageView.image) {
        [dic setObject:[NSString stringWithFormat:@"%@.png", self.teamNumberTextField.text] forKeyedSubscript:@"Photo"];
       imageURL = [directory URLByAppendingPathComponent:dic[@"Photo"]];
    }
    
    
    
    
    
    if (self.isForEditing) {
        [self saveData:dic toURL:self.fileURL withFileManager:manager];
        if (self.imageView.image) {
            [self saveImage:self.imageView.image toURL:(self.photoURL)?self.photoURL:[[self.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:dic[@"Photo"]] withFileManager:manager];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    
    if ([manager fileExistsAtPath:[fileURL path]]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Are you sure to override?" message:@"You already have the team saved for the same team number" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [ac dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [ac dismissViewControllerAnimated:YES completion:nil];
            [self saveData:dic toURL:fileURL withFileManager:manager];
            if (self.imageView.image) {
                [self saveImage:self.imageView.image toURL:imageURL withFileManager:manager];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [ac addAction:cancel];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
        
    } else {
        [self saveData:dic toURL:fileURL withFileManager:manager];
        if (self.imageView.image) {
            [self saveImage:self.imageView.image toURL:imageURL withFileManager:manager];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
    
    
}

- (void)saveData:(NSDictionary *)dic toURL:(NSURL *)fileURL withFileManager:(NSFileManager *)manager
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    if (![manager createFileAtPath:fileURL.path contents:data attributes:nil]) {
//        self.title = @"File Creation Error";
        [[[UIAlertView alloc] initWithTitle:@"File Creation Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    } else {
        [dic writeToURL:fileURL atomically:YES];
        
    }
    
}

- (void)saveImage:(UIImage *)image toURL:(NSURL *)imageURL withFileManager:(NSFileManager *)manager
{
    NSData *data = UIImagePNGRepresentation(image);
    if (![manager createFileAtPath:imageURL.path contents:data attributes:nil]) {
//        self.title = @"Image File Creation Error";
        [[[UIAlertView alloc] initWithTitle:@"Image File Creation Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)teamNumberValueChanged:(UITextField *)sender {
    self.title =[NSString stringWithFormat:@"Team: %@", sender.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
