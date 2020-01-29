//
//  RemoveDatabaseViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 1/27/20.
//  Copyright © 2020 Chase Karlen. All rights reserved.
//

#import "RemoveDatabaseViewController.h"

@interface RemoveDatabaseViewController () <UITextViewDelegate>

@property (nonatomic, strong) Helper *helper;

@end

@implementation RemoveDatabaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.removeDatabaseField.delegate = self;
    self.helper = [[Helper alloc] init];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

- (void)removeFile:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    
    if ([filename isEqualToString:self.settings.getCurrentDB]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:@"Cannot remove currently selected database"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            self.removeDatabaseField.text = @"";
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please confirm!"
                                   message:[NSString stringWithFormat:@"Will remove '%@' from list", filename]
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

- (IBAction)saveRemoveDatabase:(id)sender {
    if ([self.settings.correctedDocumentFiles containsObject:[NSString stringWithFormat:@"%@.db", self.removeDatabaseField.text]]) {
        [self removeFile:[NSString stringWithFormat:@"%@.db", self.removeDatabaseField.text]];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                   message:[NSString stringWithFormat:@"'%@.db' does not exist in the list", self.removeDatabaseField.text]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            self.removeDatabaseField.text = @"";
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
