//
//  SettingsViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 12/30/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *databasePicker;
@property (nonatomic, strong) NSString *currentDB;

@property (weak, nonatomic) IBOutlet UITextView *databaseText;
@property (weak, nonatomic) IBOutlet UITextView *removeDatabaseText;
- (IBAction)saveSettings:(id)sender;


- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
