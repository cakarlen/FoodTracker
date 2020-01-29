//
//  AddDatabaseViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 1/2/20.
//  Copyright © 2020 Chase Karlen. All rights reserved.
//

#import "AddDatabaseViewController.h"

@interface AddDatabaseViewController () <UITextViewDelegate>

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation AddDatabaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addDatabaseField.delegate = self;
    
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:[self.settings getCurrentDB]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

- (IBAction)saveAddDatabase:(id)sender {
    if (![self.settings.correctedDocumentFiles containsObject:[NSString stringWithFormat:@"%@.db", self.addDatabaseField.text]]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please confirm!"
                                   message:[NSString stringWithFormat:@"Will add %@.db to the list", self.addDatabaseField.text]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            [self.dbManager createNewDatabase:[NSString stringWithFormat:@"%@.db", self.addDatabaseField.text]];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:@"Cannot add a database that already exists"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            self.addDatabaseField.text = @"";
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
