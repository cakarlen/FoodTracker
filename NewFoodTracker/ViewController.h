//
//  ViewController.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "EditInfoViewController.h"
#import "SettingsViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  

@property (weak, nonatomic) IBOutlet UITableView *foodTable;
- (IBAction)addNewRecord:(id)sender;

@end

