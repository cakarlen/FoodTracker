//
//  AddDatabaseViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 1/2/20.
//  Copyright © 2020 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddDatabaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *addDatabaseField;
- (IBAction)saveAddDatabase:(id)sender;

@end

NS_ASSUME_NONNULL_END
