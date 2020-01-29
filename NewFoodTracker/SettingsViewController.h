//
//  SettingsViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 12/30/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

NS_ASSUME_NONNULL_BEGIN

@class AddDatabaseViewController, RemoveDatabaseViewController;

@interface SettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>

- (instancetype)init;

@property (weak, nonatomic) IBOutlet UIPickerView *databasePicker;
@property (nonatomic, strong) NSMutableArray *correctedDocumentFiles;

- (void)loadPickerData;
- (NSString *)writeForCurrentPlist:(NSString *)databaseName;
- (NSString *)getCurrentDB;
- (void)updateCurrentPlist:(NSString *)databaseName;

@end

NS_ASSUME_NONNULL_END
