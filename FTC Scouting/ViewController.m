//
//  ViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/18/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *teamNumberButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)teamNumberButtonTaped:(id)sender {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Enter Team Code" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.teamNumberButton setTitle:[NSString stringWithFormat:@"Team Number: %d", [((UITextField *)([ac.textFields firstObject])).text intValue]] forState:UIControlStateNormal];
        
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}
- (IBAction)photosButtonTapped:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera|UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    }
}

@end
