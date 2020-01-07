//
//  AddDatabaseViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 1/2/20.
//  Copyright © 2020 Chase Karlen. All rights reserved.
//

#import "AddDatabaseViewController.h"

@interface AddDatabaseViewController ()

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation AddDatabaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)saveAddDatabase:(id)sender {
    [self.dbManager createNewDatabase:[NSString stringWithFormat:@"%@.db", self.addDatabaseField.text]];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success!"
                               message:[NSString stringWithFormat:@"Added %@.db to the list", self.addDatabaseField.text]
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Great" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
