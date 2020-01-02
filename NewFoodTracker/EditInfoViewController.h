//
//  EditInfoViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "Helper.h"
#import "EntryManager.h"
#import "SettingsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EditInfoViewControllerDelegate

-(void)editingInfoWasFinished;

@end

@interface EditInfoViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *placeField;
@property (weak, nonatomic) IBOutlet UITextView *priceField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateField;

@property (nonatomic) int recordIDToEdit;
@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;

- (IBAction)saveInfo:(id)sender;

@end

NS_ASSUME_NONNULL_END
