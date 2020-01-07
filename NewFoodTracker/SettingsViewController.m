//
//  SettingsViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 12/30/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

// TODO: Look at adding a UITabBar to settings for add/delete

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) Helper *helper;
@property (nonatomic, strong) NSMutableArray *documentFiles;
@property NSMutableArray *correctedDocumentFiles;

- (BOOL)doesfileExist:(NSString *)file;

@end

@implementation SettingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"current_db.plist"];

        if ([self doesfileExist:plistPath]) {
            self.dbManager = [[DBManager alloc] initWithDatabaseFilename:[self getCurrentDB]];
        } else {
            self.dbManager = [[DBManager alloc] initWithDatabaseFilename:[self writeForCurrentPlist:@"default.db"]];
        }
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.helper = [[Helper alloc] init];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:[self getCurrentDB]];
    
    self.documentFiles = [[NSMutableArray alloc] init];
    self.documentFiles = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[self.dbManager documentsDirectory] error:nil];
    
    self.databasePicker.delegate = self;
    self.databasePicker.dataSource = self;
    self.databaseText.delegate = self;
    self.removeDatabaseText.delegate = self;
    
    // Remove occurance of current_db from documentFiles array
    self.correctedDocumentFiles = [[NSMutableArray alloc] init];
    for (NSString *file in self.documentFiles) {
        if (![file isEqualToString:@"current_db.plist"]) {
//            NSString *newFile = [file stringByReplacingOccurrencesOfString:@".db" withString:@""];
            [self.correctedDocumentFiles addObject:file];
        }
    }
    
    // Select current database as default in picker
    for (NSString *file in self.correctedDocumentFiles) {
        if ([file isEqualToString:[self getCurrentDB]]) {
            NSInteger indexOfFood = [self.correctedDocumentFiles indexOfObject:file];
            [self.databasePicker selectRow:indexOfFood inComponent:0 animated:NO];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.correctedDocumentFiles.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.correctedDocumentFiles[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // If user actually selects a new database on picker
    if (![[self getCurrentDB] isEqualToString:self.correctedDocumentFiles[row]]) {
        // Set currentDB to picker selected
        NSString *newDB = self.correctedDocumentFiles[row];
        
        // Execute query to save currentDB
        [self updateCurrentPlist:newDB];
        
        // Create actions and present alert
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
            exit(0);
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        NSArray *actions = [[NSArray alloc] initWithObjects:ok, cancel, nil];
        UIAlertController *alert = [self.helper createAlertWithTitle:@"Database changed!" withMessage:@"The app will close to confirm change" withActions:actions];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)removeFile:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    
    if ([filename isEqualToString:[self getCurrentDB]]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:@"Cannot remove currently selected database"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please confirm!"
                                   message:[NSString stringWithFormat:@"Will remove '%@.db' from list", self.removeDatabaseText.text]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            [fileManager removeItemAtPath:filePath error:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)saveSettings:(id)sender {
    if (![self.databaseText.text isEqualToString:@""] && [self.removeDatabaseText.text isEqualToString:@""]) {
        [self.dbManager createNewDatabase:[NSString stringWithFormat:@"%@.db", self.databaseText.text]];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                   message:[NSString stringWithFormat:@"Added '%@.db' to the list", self.databaseText.text]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Great" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if ([self.databaseText.text isEqualToString:@""] && [self.correctedDocumentFiles containsObject:[NSString stringWithFormat:@"%@.db", self.removeDatabaseText.text]]) {
        [self removeFile:[NSString stringWithFormat:@"%@.db", self.removeDatabaseText.text]];
        
    } else if ([self.databaseText.text isEqualToString:@""] && ![self.correctedDocumentFiles containsObject:[NSString stringWithFormat:@"%@.db", self.removeDatabaseText.text]]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:[NSString stringWithFormat:@"'%@.db' does not exist in the list", self.removeDatabaseText.text]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            self.removeDatabaseText.text = @"";
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if ([self.databaseText.text isEqualToString:@""] && [self.removeDatabaseText.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:@"Please enter something in one of the fields"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                       message:@"Both fields cannot be filled out"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
            self.databaseText.text = @"";
            self.removeDatabaseText.text = @"";
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString *)writeForCurrentPlist:(NSString *)databaseName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"current_db.plist"];
    NSArray *current = [[NSArray alloc] initWithObjects:databaseName, nil];
    
    NSDictionary *plistDict = [[NSDictionary alloc] initWithObjects:current forKeys:[NSArray arrayWithObjects:@"current", nil]];
    
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if (plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        return databaseName;
    } else {
        return @"";
    }
}

- (NSString *)getCurrentDB {
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"current_db.plist"];
    
    if (![self doesfileExist:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"current_db" ofType:@"plist"];
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return [dict objectForKey:@"current"];
}

- (void)updateCurrentPlist:(NSString *)databaseName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"current_db.plist"];
    
    if (![self doesfileExist:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"current_db" ofType:@"plist"];
    }
    
    NSMutableDictionary *oldData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [oldData removeAllObjects];
    [oldData setValue:databaseName forKey:@"current"];
    [oldData writeToFile:plistPath atomically:YES];
}
            
- (BOOL)doesfileExist:(NSString *)file {
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return YES;
    } else {
        return NO;
    }
}

@end
