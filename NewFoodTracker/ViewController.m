//
//  ViewController.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

// TODO: Add Settings and init with database name within settings

#import "ViewController.h"

@interface ViewController () <EditInfoViewControllerDelegate>

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) SettingsViewController *settings;
@property (nonatomic, strong) NSArray *arrFoodInfo;
@property (nonatomic, strong) NSMutableArray *resultsTitles;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic) int recordIDToEdit;

-(void)loadData;

@end

@implementation ViewController

#pragma mark - Load stuff

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.settings = [[SettingsViewController alloc] init];
    self.dbManager = [[DBManager alloc] init];
    
    self.foodTable.delegate = self;
    self.foodTable.dataSource = self;

    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:[self.settings currentDB]];
    
    [self loadData];
}

- (void)loadData {
    // Form the query.
    NSString *query = @"select * from food";
    
    // Get the results.
    if (self.arrFoodInfo != nil) {
        self.arrFoodInfo = nil;
    }
    
    if (_results != nil) {
        _results = nil;
    }
    
    self.resultsTitles = [[NSMutableArray alloc] init];
    self.arrFoodInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query forDatabase:@"food"]];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    for (NSDictionary *dict in self.arrFoodInfo) {

        NSString *date = [dict objectForKey:@"DATE"];

        NSDateFormatter *SDF = [[NSDateFormatter alloc]
                                 init];
        [SDF setDateStyle:NSDateFormatterMediumStyle];
        [SDF setDateFormat:@"MM/dd/yyyy"];
        NSDate *convertedDate = [SDF dateFromString:date];

        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitWeekOfYear fromDate:convertedDate];

        NSInteger week = dateComponents.weekOfYear;
        NSInteger index = week;
        NSNumber *key = @(index);
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        if ([[tempDict allKeys] containsObject:key]) {
            tempArray = [tempDict[key] mutableCopy];
        }

        [tempArray addObject:dict];
        [tempDict setObject:tempArray forKey:key];
    }
    
    EntryManager *entryManager = nil;
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
    for (id weekNum in [tempDict allKeys]) {
        entryManager = [[EntryManager alloc] initWithWeek:weekNum withDict:[tempDict objectForKey:weekNum]];
        [tempArr addObject:entryManager];
    }
    
    _results = tempArr;
    
    for (id entry in _results) {
        if (![_resultsTitles containsObject:[entry weekNumber]]) {
            [_resultsTitles addObject:[entry weekNumber]];
        }
    }

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *reverseTitles = [_resultsTitles sortedArrayUsingDescriptors:descriptors];
    _resultsTitles = reverseTitles;
    
#if DEBUG
    DLog(@"arrFoodInfo is: %@", [self arrFoodInfo]);
#endif
    
    // Reload the table view.
    [self.foodTable reloadData];
}

#pragma mark - Table setup

- (NSInteger)getIndexAtWeek:(NSNumber *)week {
    NSInteger realIndex = -1;
    
    for (id temp in _results) {
        if ([temp weekNumber] == week) {
            return realIndex = [_results indexOfObject:temp];
        }
    }
    
    return realIndex;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_resultsTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSNumber *weekNum = [_resultsTitles objectAtIndex:section];
    NSInteger index = [self getIndexAtWeek:weekNum];
    
    NSNumber *total = [[_results objectAtIndex:index] total];
    
    NSString *placeHolder = [NSString stringWithFormat:@"Week %@ | Total: $%@", [[_resultsTitles objectAtIndex:section] stringValue], total];
    return placeHolder;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber *weekNum = [_resultsTitles objectAtIndex:section];
    NSInteger index = [self getIndexAtWeek:weekNum];
    
    NSArray *sectionResults = [[_results objectAtIndex:index] purchasesArr];
    return [sectionResults count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue the cell.
    static NSString *identifier = @"idCellRecord";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    NSNumber *weekNum = [_resultsTitles objectAtIndex:indexPath.section];
    NSInteger index = [self getIndexAtWeek:weekNum];
    
    EntryManager *sectionResults = [_results objectAtIndex:index];
    PurchaseManager *cellData = [[sectionResults purchasesArr] objectAtIndex:indexPath.row];
    NSDictionary *actualData = nil;
    
    actualData = @{ @"PLACE": cellData.place, @"PRICE": cellData.price, @"DATE": cellData.date };

    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ | $%@", [actualData valueForKey:@"PLACE"], [actualData valueForKey:@"PRICE"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Date: %@", [actualData valueForKey:@"DATE"]];
    
    return cell;
}

// When user slides to delete an entry
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSNumber *weekNum = [_resultsTitles objectAtIndex:indexPath.section];
        NSInteger index = [self getIndexAtWeek:weekNum];
        
        EntryManager *sectionResults = [_results objectAtIndex:index];
        PurchaseManager *cellData = [[sectionResults purchasesArr] objectAtIndex:indexPath.row];

        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[cellData idNum] intValue];

        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from food where id=%d", recordIDToDelete];

        // Execute the query.
        [self.dbManager executeQuery:query forDatabase:@"food"];

        // Reload the table view.
        [self loadData];
    }
}

// When user edits an entry
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    NSNumber *weekNum = [_resultsTitles objectAtIndex:indexPath.section];
    NSInteger index = [self getIndexAtWeek:weekNum];
    
    EntryManager *sectionResults = [_results objectAtIndex:index];
    PurchaseManager *cellData = [[sectionResults purchasesArr] objectAtIndex:indexPath.row];

    self.recordIDToEdit = [[cellData idNum] intValue];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}

// Helper function
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Because I didn't know another way to do this
    if ([[segue identifier] isEqual:@"idSegueEditInfo"]) {
        EditInfoViewController *editInfoViewController = [segue destinationViewController];
        editInfoViewController.delegate = self;
        editInfoViewController.recordIDToEdit = self.recordIDToEdit;
    } else if ([[segue identifier] isEqual:@"goToSettings"]) {
        SettingsViewController *settingsViewController = [segue destinationViewController];
        settingsViewController.currentDB = [self.dbManager databaseFilename];
    }
}

#pragma mark - Actions

-(void)editingInfoWasFinished {
    // Reload the data.
    [self loadData];
}

- (IBAction)addNewRecord:(id)sender {
    self.recordIDToEdit = -1;
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}

- (IBAction)clickedSettings:(id)sender {
    [self performSegueWithIdentifier:@"goToSettings" sender:self];
}

@end
