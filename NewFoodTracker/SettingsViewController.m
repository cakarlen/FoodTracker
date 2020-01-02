//
//  SettingsViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 12/30/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

// TODO: Look at adding a UITabBar to settings for add/delete
// TODO: Streamline DBManager using createNewDatabase

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSMutableArray *documentFiles;
@property NSMutableArray *correctedDocumentFiles;

@end

@implementation SettingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"food.db"];
        
        NSString *findDatabase = @"select * from current_db";
        NSArray *currentDB = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:findDatabase forDatabase:@"current"]];
        self.currentDB = [[currentDB objectAtIndex:0] objectForKey:@"DATABASE"];
        
        if (![[self.dbManager databaseFilename] isEqualToString:self.currentDB]) {
            self.dbManager = [[DBManager alloc] initWithDatabaseFilename:self.currentDB];
            self.currentDB = [self.dbManager databaseFilename];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:self.currentDB];
    
    self.documentFiles = [[NSMutableArray alloc] init];
    self.documentFiles = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[self.dbManager documentsDirectory] error:nil];
    
    self.databasePicker.delegate = self;
    self.databasePicker.dataSource = self;
    self.databaseText.delegate = self;
    self.removeDatabaseText.delegate = self;
    
    // Remove occurance of current_db from documentFiles array
    self.correctedDocumentFiles = [[NSMutableArray alloc] init];
    for (NSString *file in self.documentFiles) {
        if (![file isEqualToString:@"current_db.db"]) {
            [self.correctedDocumentFiles addObject:file];
        }
    }
    
    // Select current database as default in picker
    for (NSString *file in self.correctedDocumentFiles) {
        if ([file isEqualToString:self.currentDB]) {
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
    if (![self.currentDB isEqualToString:self.correctedDocumentFiles[row]]) {
        self.currentDB = self.correctedDocumentFiles[row];
        
        NSString *query = [NSString stringWithFormat:@"update current_db set DATABASE='%@' where id=%d", self.currentDB, 1];
        [self.dbManager executeQuery:query forDatabase:@"current"];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Database changed!"
                                   message:@"The app will close to confirm change"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            exit(0);
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)removeFile:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    
    if ([filename isEqualToString:self.currentDB]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:@"Cannot remove currently selected database"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            [fileManager removeItemAtPath:filePath error:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please confirm!"
                                   message:[NSString stringWithFormat:@"Will remove %@.db from list", self.removeDatabaseText.text]
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
                                   message:[NSString stringWithFormat:@"Added %@.db to the list", self.databaseText.text]
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
                                   message:[NSString stringWithFormat:@"%@.db does not exist in the list", self.removeDatabaseText.text]
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

@end
