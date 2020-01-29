//
//  SettingsViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 12/30/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//
// TODO: Look at hitting delete button on selected row of picker to delete instead of prompting new VC

#import "SettingsViewController.h"
#import "AddDatabaseViewController.h"
#import "RemoveDatabaseViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) Helper *helper;
@property (nonatomic, strong) NSMutableArray *documentFiles;

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
    
    self.databasePicker.delegate = self;
    self.databasePicker.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadPickerData];
}

- (void)loadPickerData {
    self.documentFiles = [[NSMutableArray alloc] init];
    self.documentFiles = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[self.dbManager documentsDirectory] error:nil];
    
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
    
    [[self databasePicker] reloadAllComponents];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Because I didn't know another way to do this
    if ([[segue identifier] isEqual:@"addDatabaseSegue"]) {
        AddDatabaseViewController *add = [segue destinationViewController];
        [add setSettings:self];
    } else if ([[segue identifier] isEqual:@"removeDatabaseSegue"]) {
        RemoveDatabaseViewController *remove = [segue destinationViewController];
        [remove setSettings:self];
    }
}

@end
