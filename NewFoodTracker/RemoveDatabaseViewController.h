//
//  RemoveDatabaseViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 1/27/20.
//  Copyright © 2020 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helper.h"
#import "SettingsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingsViewController;

@interface RemoveDatabaseViewController : UIViewController <UITextViewDelegate>

//@property (nonatomic, strong) SettingsViewController *settings;

@property (weak, nonatomic) IBOutlet UITextView *removeDatabaseField;
- (IBAction)saveRemoveDatabase:(id)sender;

@end

NS_ASSUME_NONNULL_END
