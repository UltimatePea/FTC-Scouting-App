//
//  ScoutingTableViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/18/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "ScoutingTableViewController.h"
#import "NSURL+Directory.h"

@interface ScoutingTableViewController () <UITextFieldDelegate>

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
//@property (strong, nonatomic) NSURL *documentURL;

@property (strong, nonatomic) NSDictionary *teamInfo, *matchInfo;

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
    return @[@"Descend Ramp (20 points)",
             @"Score Rolling Goal (30 points)",
             @"Drag Rolling Goal into Parking Area (20 points)",
             @"Hit Kick Stand (30 points)",
             @"Score Center Goal (60 points)",
             @"Auto Didn't Move", @"Driver Controlled Didn't Move"];
}

- (NSArray *)heightTitle
{
    return @[@"90cm Score (3 points per cm)",
             @"60cm Score (2 points per cm)",
             @"30cm Score (1 points per cm)",
             @"120cm Score (6 points per cm)"];
}

- (NSArray *)stopTitle
{
    return @[@"Number on Ramp (30 points per item)",
             @"Number in Parking Area (10 points per item)"];
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
        NSMutableArray *data = [NSMutableArray array];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *directory = [[[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"teams/"];
        
        if ([manager fileExistsAtPath:directory.path]) {
            NSError *dirErr;
            //self.rootURL = directory;
            NSArray *urls = [manager contentsOfDirectoryAtURL:directory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&dirErr];
            if (dirErr) {
//                self.title = @"Directory Read Error";
                [[[UIAlertView alloc] initWithTitle:@"Directory Read Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return nil;
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
                    [data addObject:dictionary];
                    if (dictionary[@"Team Name"]&&dictionary[@"Team Number"]) {
                        [dic setObject:dictionary[@"Team Name"] forKeyedSubscript:dictionary[@"Team Number"]];
                    }
                    
                }
            }];
        }
        _teamInfo = dic;
        
    }
    return _teamInfo;
}

- (NSDictionary *)matchInfo
{
    if (!_matchInfo) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"B matches" withExtension:@".csv"];
        NSError *error;
        NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error) {
//            self.title = @"Match Infomation Read Error";
            [[[UIAlertView alloc] initWithTitle:@"Match Infomation Read Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return nil;
        }
        NSMutableDictionary *matchInfo = [NSMutableDictionary dictionary];
        NSArray *rows = [str componentsSeparatedByString:@"\r\n"];
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *row = obj;
            NSArray *values = [row componentsSeparatedByString:@","];
            NSString *key = [values firstObject];
            NSRange range;
            range.location = 1;
            range.length = 4;
            [matchInfo setObject:[values subarrayWithRange:range] forKey:key];
        }];
        _matchInfo = matchInfo;
    }
    return _matchInfo;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (IBAction)changeTeamNumber:(UIButton *)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Enter Number" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        if (![self.teamNumber containsObject:sender]) {
            textField.text = sender.titleLabel.text;
        }
        
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
            NSString *title = [self.teamInfo objectForKey:[NSString stringWithFormat:@"%d", [name intValue]]];
            if (title) {
                [nameButton setTitle:title forState:UIControlStateNormal];
            }
            
            [self updateTitle];
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
                textField.text = [textField.text stringByAppendingString:[NSString stringWithFormat:@"Score：%@；Item：%@\r\n",[dic objectForKey:text], text]];
            }];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
    
}

//- (NSURL *)documentURL
//{
//    if (!_documentURL) {
//        NSFileManager *manager = [NSFileManager defaultManager];
//        NSURL *documentsDirectory = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
//        NSString *documentName = @"Database";
//        NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
//        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
//        
//        BOOL fileExists = [manager fileExistsAtPath:[url path]];
//        if (fileExists) {
//            [document openWithCompletionHandler:^(BOOL success) {
//                if (success) {
//                    
//                } else {
//                    NSLog(@"Couldn't open document at %@", url);
//                }
//            }];
//        } else {
//            [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//                if (success) {
//                    
//                } else {
//                    NSLog(@"Couldn't create document at %@", url);
//                }
//            }];
//        }
//    }
//    return _documentURL;
//}

- (NSString *)matchUniqueID
{
    return [NSString stringWithFormat:@"%@ & %@ v.s. %@ & %@", [self getTeamNumberAtIndex:0], [self getTeamNumberAtIndex:1], [self getTeamNumberAtIndex:2], [self getTeamNumberAtIndex:3]];
}

- (NSString *)getTeamNumberAtIndex:(int)idx
{
    UIButton *button = [self.teamNumber objectAtIndex:idx];
    return button.titleLabel.text;
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
            [dic setObject:teamNumber.titleLabel.text forKey:@"Team Number"];
            [dic setObject:teamName.titleLabel.text forKey:@"Team Name"];
            [dic setObject:score.titleLabel.text forKey:@"Total Score"];
            [dic setObject:comment.text forKey:@"Notes"];
            [dic setObject:rank.text forKey:@"Ranks"];
            [dic setObject:detailedScore forKey:@"Detailed Score"];
            [dic setObject:[NSNumber numberWithBool:autoNeverMoves.on] forKey:@"Auto Didn't Move"];
            [dic setObject:[NSNumber numberWithBool:manualNeverMoves.on] forKey:@"Driver Controlled Didn't Move"];
            [dic setObject:[self matchUniqueID] forKeyedSubscript:@"Match Info"];
           
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterMediumStyle;
            formatter.timeStyle = NSDateFormatterMediumStyle;
            
            [dic setObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] forKey:@"Date"];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            NSURL *documentsDirectory = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
            documentsDirectory = [documentsDirectory URLByAppendingPathComponent:@"matches/"];
            if (![manager fileExistsAtPath:[documentsDirectory path] isDirectory:NULL]) {
                NSError *mkdirErr;
                [manager createDirectoryAtPath:[documentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&mkdirErr];
                if (mkdirErr) {
//                    self.title = @"Directory creation error";
                    [[[UIAlertView alloc] initWithTitle:@"Directory creation error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    return;
                }
            }
            NSString *documentDir = [NSString stringWithFormat:@"%@", teamNumber.titleLabel.text];
            NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentDir];
            
            NSLog(@"Save to URL: %@", url);
            
            NSError *error;
            [manager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
//                self.title = @"Directory creation error";
                [[[UIAlertView alloc] initWithTitle:@"Directory creation error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
            url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@.plist", [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]]];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
            if (![manager createFileAtPath:[url path] contents:data attributes:nil]) {
//                self.title = @"File Creation Error";
                [[[UIAlertView alloc] initWithTitle:@"File Creation Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
            
            [dic writeToURL:url atomically:YES];
            
        }];
        [self.navigationController popViewControllerAnimated:YES];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
//        self.title = @"Please first complete \'operations\'.";
        [[[UIAlertView alloc] initWithTitle:@"Please first complete \'operations\'." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    @finally {
        
    }
    
}

- (IBAction)enterMatchNumber:(id)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Enter Match Number" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        
    }];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *array = [self.matchInfo objectForKey:((UITextField *)[[ac textFields] firstObject]).text];
        if (array) {
            [self.teamNumber enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIButton *button = obj;
                [button setTitle:[array objectAtIndex:idx] forState:UIControlStateNormal];
                [self updateTitle];
            }];
            [self.teamName enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIButton *name = obj;
                //UIButton *number = [self.teamNumber objectAtIndex:idx];
                
                [name setTitle:[self.teamInfo objectForKey:[array objectAtIndex:idx]] forState:UIControlStateNormal];
            }];
        }
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [ac addAction:actionOK];
    [ac addAction:cancel];
    
    [self presentViewController:ac animated:YES completion:nil];
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations];
}

- (void)updateTitle
{
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:.2] interval:0 target:self selector:@selector(updateTitleTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}
- (void)updateTitleTimer:(NSTimer *)timer
{
    self.navigationItem.prompt = @"";
    [self.teamNumber enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        self.navigationItem.prompt = [NSString stringWithFormat:@"%@   ||   %@", self.navigationItem.prompt, button.titleLabel.text];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.commentTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}




@end
