//
//  ScoutingTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/18/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "ScoutingTableViewController.h"

@interface ScoutingTableViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *teamNumber;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *teamName;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *autonomousNotMovingSwitch;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *manualNotMovingSwitch;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *height;
@property (strong, nonatomic) IBOutletCollection(UIStepper) NSArray *heightStepper;
@property (strong, nonatomic) IBOutletCollection(UIStepper) NSArray *heightStepperActualValue;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stopCount;
@property (strong, nonatomic) IBOutletCollection(UIStepper) NSArray *stopStepper;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *atonomousSwitch;
@property (strong, nonatomic) NSArray *scoresOfSwitch, *scoresOfHeight, *scoresOfStop;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *scoreSum;

@property (strong, nonatomic) NSArray *autonomousTitle, *heightTitle, *stopTitle;

@property (strong, nonatomic) NSArray *rank;
@property (strong, nonatomic) IBOutletCollection(UITextView) NSArray *rankTextField;
@property (strong, nonatomic) NSURL *documentURL;

@property (strong, nonatomic) NSDictionary *teamInfo;

@end

@implementation ScoutingTableViewController

- (NSArray *)scoresOfSwitch
{
    return @[@20, @30, @20, @30, @60, @0, @0];
}

- (NSArray *)scoresOfHeight
{
    return @[@3, @2, @1, @6];
}

- (NSArray *)scoresOfStop
{
    return @[@30, @10];
}

- (NSArray *)autonomousTitle
{
    return @[@"下坡20分", @"向滚动球桶投球30分", @"向滚动球桶拖入驻停区20分", @"成功撞杆30分", @"向中心球桶投球60分", @"未动0分", @"手动未动0分"];
}

- (NSArray *)heightTitle
{
    return @[@"90厘米桶", @"60厘米桶", @"30厘米桶", @"120厘米中心球桶"];
}

- (NSArray *)stopTitle
{
    return @[@"停在坡上", @"停在驻停区"];
}

- (NSArray *)rank
{
    if (!_rank) {
        _rank = [NSArray array];
    }
    return _rank;
}


- (NSDictionary *)teamInfo
{
    if (!_teamInfo) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Team Info" withExtension:@".csv"];
        NSError *error;
        NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            self.title = @"Team Infomation Read Error";
        }
        NSMutableDictionary *teamInfo = [NSMutableDictionary dictionary];
        NSArray *rows = [str componentsSeparatedByString:@"\r\n"];
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *row = obj;
            NSArray *keyAndValue = [row componentsSeparatedByString:@","];
            [teamInfo setObject:[keyAndValue lastObject] forKey:[keyAndValue firstObject]];
        }];
        _teamInfo = teamInfo;
    }
    return _teamInfo;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (IBAction)changeTeamNumber:(UIButton *)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Enter Number" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text = sender.titleLabel.text;
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([((UITextField *)([ac.textFields firstObject])).text isEqualToString:@""] ) {
            return ;
        }
        NSString *name =((UITextField *)([ac.textFields firstObject])).text;
        [sender setTitle:[NSString stringWithFormat:@"%d", [name intValue]]  forState:UIControlStateNormal];
        if ([self.teamNumber containsObject:sender]) {
            NSUInteger idx = [self.teamNumber indexOfObject:sender];
            UIButton *nameButton = [self.teamName objectAtIndex:idx];
            [nameButton setTitle:[self.teamInfo objectForKey:[NSString stringWithFormat:@"%d", [name intValue]]] forState:UIControlStateNormal];
        }
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}


- (IBAction)changeTeamName:(UIButton *)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Enter Team Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.text = sender.titleLabel.text;
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [sender setTitle:[NSString stringWithFormat:@"%@", ((UITextField *)([ac.textFields firstObject])).text ] forState:UIControlStateNormal];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}
#define HEIGHT_PER_BIG_BALL 7.1
- (IBAction)stepperChanged:(UIStepper *)sender {
    if ([self.heightStepper containsObject:sender]) {
        NSUInteger index = [self.heightStepper indexOfObject:sender];
        unsigned targetIndex = ((int)(index / 4) * 2 + 1) * 4 + index%4;
        UIButton *button = [self.height objectAtIndex:targetIndex];
        [button setTitle:[NSString stringWithFormat:@"%d", (int)sender.value] forState:UIControlStateNormal];
        UIButton *heightButton = [self.height objectAtIndexedSubscript:targetIndex - 4];
        UIStepper *actualStepper = [self.heightStepperActualValue objectAtIndex:index];
        
        [heightButton setTitle:[NSString stringWithFormat:@"%d", (int)(sender.value * HEIGHT_PER_BIG_BALL + actualStepper.value )] forState:UIControlStateNormal];
    } else if ([self.stopStepper containsObject:sender]){
        NSUInteger index = [self.stopStepper indexOfObject:sender];
        NSUInteger targetIndex = index;
        UIButton *button = [self.stopCount objectAtIndex:targetIndex];
        [button setTitle:[NSString stringWithFormat:@"%d", (int)sender.value] forState:UIControlStateNormal];
    }
    
}

- (IBAction)actualValueStepperValueChanged:(UIStepper *)sender
{
    if ([self.heightStepperActualValue containsObject:sender]) {
        NSUInteger index = [self.heightStepperActualValue indexOfObject:sender];
        unsigned targetIndex = ((int)(index / 4) * 2 + 0) * 4 + index%4;
        UIButton *button = [self.height objectAtIndex:targetIndex];
        
        unsigned targetIndexOfHeight = ((int)(index / 4) * 2 + 1) * 4 + index%4;
        UIButton *buttonHeight = [self.height objectAtIndex:targetIndexOfHeight];
        
        
        [button setTitle:[NSString stringWithFormat:@"%d", (int)sender.value + [buttonHeight.titleLabel.text intValue] * 7] forState:UIControlStateNormal];
        
    }
}

- (IBAction)updateScoreSum
{
    //NSMutableArray *result = [NSMutableArray arrayWithObjects: @0, @0, @0, @0, nil];
    __block int result0 = 0, result1 = 0, result2 = 0, result3 = 0;
    NSArray *scoresOfFourTeam = [NSArray arrayWithObjects:[NSMutableDictionary dictionary], [NSMutableDictionary dictionary], [NSMutableDictionary dictionary], [NSMutableDictionary dictionary], nil];
    
    [self.atonomousSwitch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UISwitch *currentSwitch = obj;
        int increment = [[self.scoresOfSwitch objectAtIndex:((int)idx/4)] intValue] * ((currentSwitch.on)?1:0);

        switch (idx%4) {
            case 0:
                result0+=increment;
                
                break;
            case 1:
                result1 += increment;
                break;
            case 2:
                result2 += increment;
                break;
            case 3:
                result3 += increment;
                break;
            default:
                return;
                break;
        }
        
        NSMutableDictionary *dic = [scoresOfFourTeam objectAtIndex:idx%4];
        [dic setObject:[NSNumber numberWithInt:increment] forKeyedSubscript:[self.autonomousTitle objectAtIndex:((int)idx/4)]];
    }];
    
    [self.height enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        int increment = [[self.scoresOfHeight objectAtIndex:((int)idx/8)] intValue] * [button.titleLabel.text intValue];
        switch (idx%8) {
            case 0:
                result0+=increment;
                break;
            case 1:
                result1 += increment;
                break;
            case 2:
                result2 += increment;
                break;
            case 3:
                result3 += increment;
                break;
            default:
                return;
                break;
        }
        @try {
            NSMutableDictionary *dic = [scoresOfFourTeam objectAtIndex:idx%8];
            [dic setObject:[NSNumber numberWithInt:increment] forKeyedSubscript:[self.heightTitle objectAtIndex:((int)idx/8)]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            
        }
        
    }];
    [self.stopCount enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        int increment = [[self.scoresOfStop objectAtIndex:((int)idx/4)] intValue] * [button.titleLabel.text intValue];
        switch (idx%4) {
            case 0:
                result0+=increment;
                break;
            case 1:
                result1 += increment;
                break;
            case 2:
                result2 += increment;
                break;
            case 3:
                result3 += increment;
                break;
            default:
                return;
                break;
        }
        NSMutableDictionary *dic = [scoresOfFourTeam objectAtIndex:idx%4];
        [dic setObject:[NSNumber numberWithInt:increment] forKeyedSubscript:[self.stopTitle objectAtIndex:((int)idx/4)]];
    }];
    self.rank = scoresOfFourTeam;
    
    [self.scoreSum enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *score = obj;
        switch (idx) {
            case 0:
                [score setTitle:[NSString stringWithFormat:@"%d", result0] forState:UIControlStateNormal];
                break;
            case 1:
                [score setTitle:[NSString stringWithFormat:@"%d", result1] forState:UIControlStateNormal];;
                break;
            case 2:
                [score setTitle:[NSString stringWithFormat:@"%d", result2] forState:UIControlStateNormal];;
                break;
            case 3:
                [score setTitle:[NSString stringWithFormat:@"%d", result3] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
    }];
    
}

- (IBAction)generateRankInfo:(id)sender
{
    @try {
        [self.rankTextField enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = [self.rank objectAtIndex:idx];
            UITextField *textField = obj;
            textField.text = @"\r\n";
            NSArray *keys =[dic keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                int value1 = [obj1 intValue];
                int value2 = [obj2 intValue];
                if (value1 == value2) {
                    return NSOrderedSame;
                } else {
                    return value1>value2?NSOrderedAscending:NSOrderedDescending;
                }
            }];
           // NSArray *keys = [dic allKeys];
            [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *text = obj;
                textField.text = [textField.text stringByAppendingString:[NSString stringWithFormat:@"得分：%@；项目：%@\r\n",[dic objectForKey:text], text]];
            }];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
    
}

- (NSURL *)documentURL
{
    if (!_documentURL) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = @"Database";
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        
        BOOL fileExists = [manager fileExistsAtPath:[url path]];
        if (fileExists) {
            [document openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    
                } else {
                    NSLog(@"Couldn't open document at %@", url);
                }
            }];
        } else {
            [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success) {
                    
                } else {
                    NSLog(@"Couldn't create document at %@", url);
                }
            }];
        }
    }
    return _documentURL;
}

- (IBAction)save:(id)sender
{
    @try {
        [self.teamNumber enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *teamNumber = obj;
            UIButton *teamName = [self.teamName objectAtIndex:idx];
            UIButton *score = [self.scoreSum objectAtIndex:idx];
            UITextField *comment = self.commentTextField;
            UITextView *rank = [self.rankTextField objectAtIndex:idx];
            NSDictionary *detailedScore = [self.rank objectAtIndex:idx];
            UISwitch *autoNeverMoves = [self.autonomousNotMovingSwitch objectAtIndex:idx];
            UISwitch *manualNeverMoves = [self.manualNotMovingSwitch objectAtIndex:idx];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:teamNumber.titleLabel.text forKey:@"队伍编号"];
            [dic setObject:teamName.titleLabel.text forKey:@"队伍名称"];
            [dic setObject:score.titleLabel.text forKey:@"总分"];
            [dic setObject:comment.text forKey:@"备注"];
            [dic setObject:rank.text forKey:@"各项比分排名"];
            [dic setObject:detailedScore forKey:@"详细分数"];
            [dic setObject:[NSNumber numberWithBool:autoNeverMoves.on] forKey:@"自动阶段未动"];
            [dic setObject:[NSNumber numberWithBool:manualNeverMoves.on] forKey:@"手动阶段未动"];
            
            
            NSFileManager *manager = [NSFileManager defaultManager];
            NSURL *documentsDirectory = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterMediumStyle;
            formatter.timeStyle = NSDateFormatterMediumStyle;
            NSString *documentDir = [NSString stringWithFormat:@"%@", teamNumber.titleLabel.text];
            NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentDir];
            
            NSLog(@"Save to URL: %@", url);
            
            NSError *error;
            [manager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                self.title = @"Directory creation error";
                return;
            }
            url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@.plist", [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]]];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
            if (![manager createFileAtPath:[url path] contents:data attributes:nil]) {
                self.title = @"File Creation ERROR";
            }
            
            [dic writeToURL:url atomically:YES];
            
        }];
        [self.navigationController popViewControllerAnimated:YES];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        self.title = @"An error has occurred during saving.";
        
    }
    @finally {
        
    }
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations];
}


@end
