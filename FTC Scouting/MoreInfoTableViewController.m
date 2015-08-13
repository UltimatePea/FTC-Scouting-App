//
//  MoreInfoTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 4/14/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "MoreInfoTableViewController.h"

@interface MoreInfoTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *matchRecordStyleClassicSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *scoreNotingClassicSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *contributorNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *contributionValueCell;
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

@implementation MoreInfoTableViewController

- (NSUserDefaults *)defaults
{
    if (!_defaults) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}

- (void)update
{
    if ([self.defaults objectForKey:@"Match Record Style"]) {
        if ([[self.defaults objectForKey:@"Match Record Style"] intValue] == 1) {
            self.matchRecordStyleClassicSwitch.on = YES;
        } else {
            self.matchRecordStyleClassicSwitch.on = NO;
        }
    }
    if ([self.defaults objectForKey:@"Scouting Table Style"]) {
        if ([[self.defaults objectForKey:@"Scouring Table Style"] intValue] == 1) {
            self.scoreNotingClassicSwitch.on = YES;
        } else {
            self.scoreNotingClassicSwitch.on = NO;
        }
    }
    if ([self.defaults objectForKey:@"Contributor"]) {
        self.contributorNameCell.detailTextLabel.text = [self.defaults objectForKey:@"Contributor"];
        
    }
    if ([self.defaults objectForKey:@"Credit"]) {
        self.contributionValueCell.detailTextLabel.text = [ NSString stringWithFormat:@"%d", [[self.defaults objectForKey:@"Credit"] intValue] / 10];
    }
    
}

- (IBAction)matchRecordSwitchValueChanged:(UISwitch *)sender {
    [self.defaults setObject:[NSNumber numberWithInt:sender.on?1:0] forKey:@"Match Record Style"];
}

- (IBAction)scoreNotingSwitchValueChanged:(UISwitch *)sender {
    [self.defaults setObject:[NSNumber numberWithInt:sender.on?1:0] forKey:@"Scouring Table Style"];
}

- (IBAction)changeContributorName:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Your Name" message:@"We will record your name as contributor of information." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        if ([self.defaults objectForKey:@"Contributor"]) {
            textField.text = [self.defaults objectForKey:@"Contributor"];
        }
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
        NSString *userName =((UITextField *)[[alertController textFields] firstObject]).text;
        [self.defaults setObject:userName forKey:@"Contributor"];
        [self update];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[self.tableView cellForRowAtIndexPath:indexPath] isEqual:self.contributorNameCell]) {
        [self changeContributorName:self.contributorNameCell];
    }
}

@end
