//
//  AddDatabaseViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 1/2/20.
//  Copyright © 2020 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "SettingsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingsViewController;

@interface AddDatabaseViewController : UIViewController <UITextViewDelegate>

//@property (nonatomic, strong) SettingsViewController *settings;

@property (weak, nonatomic) IBOutlet UITextView *addDatabaseField;
- (IBAction)saveAddDatabase:(id)sender;

@end

NS_ASSUME_NONNULL_END
