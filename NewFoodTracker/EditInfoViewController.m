//
//  EditInfoViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController () <UITextViewDelegate>

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) SettingsViewController *settings;
@property (nonatomic, strong) EntryManager *entryManager;
@property (nonatomic, strong) Helper *help;

-(void)loadInfoToEdit;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    self.settings = [[SettingsViewController alloc] init];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:[self.settings currentDB]];
    self.help = [[Helper alloc] init];
    
    _priceField.delegate = self;
    _placeField.delegate = self;
    
    if (self.recordIDToEdit != -1) {
        // Load the record with the specific ID from the database.
        [self loadInfoToEdit];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (IBAction)saveInfo:(id)sender {
    // Prepare the query string.
    // If the recordIDToEdit property has value other than -1, then create an update query. Otherwise create an insert query.
    NSString *query;
    NSString *dateString = [_help convertDateToString:_dateField];
    NSString *spentValue = [_help stringByFormattingString:self.priceField.text toPrecision:02];
    
    if (self.recordIDToEdit == -1) {
        query = [NSString stringWithFormat:@"insert into food values(null, '%@', '%@', '%@')", self.placeField.text, spentValue, dateString];
    } else {
        query = [NSString stringWithFormat:@"update food set place='%@', price='%f', date='%@' where id=%d", self.placeField.text, [spentValue floatValue], dateString, self.recordIDToEdit];
    }
    
    // Execute the query.
    [self.dbManager executeQuery:query forDatabase:@"food"];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
#if DEBUG
        DLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        DLog(@"Got query: %@", query);
#endif
        
        // Inform the delegate that the editing was finished.
        [self.delegate editingInfoWasFinished];
        
        // Pop the view controller.
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        DLog(@"Could not execute the query.");
    }
}

-(void)loadInfoToEdit {
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from food where id=%d", self.recordIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query forDatabase:@"food"]];
    
    NSString *dateString = [[results objectAtIndex:0] valueForKey:@"DATE"];
    NSDate *convertedDate = [_help convertStringToDate:dateString];
    
    // Set the loaded data to the textfields.
    self.placeField.text = [[results objectAtIndex:0] valueForKey:@"PLACE"];
    self.priceField.text = [[results objectAtIndex:0] valueForKey:@"PRICE"];
    [_dateField setDate:convertedDate];
}

@end
