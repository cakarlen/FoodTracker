//
//  EntryManager.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/15/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import "EntryManager.h"

@interface EntryManager()
@end

@implementation EntryManager

- (instancetype)initWithWeek:(NSNumber *)week withDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _weekNumber = week;
        self.purchasesArr = [[NSMutableArray alloc] init];
        
        for (NSDictionary *tempDict in dict) {
            PurchaseManager *purchase = [[PurchaseManager alloc] init];
            
            [purchase setIdNum:[tempDict valueForKey:@"ID"]];
            [purchase setPlace:[tempDict valueForKey:@"PLACE"]];
            [purchase setPrice:[tempDict valueForKey:@"PRICE"]];
            [purchase setDate:[tempDict valueForKey:@"DATE"]];
            
            NSNumber *price = [tempDict valueForKey:@"PRICE"];
            
            _total = [NSNumber numberWithFloat:([price floatValue] + [_total floatValue])];
            
            [self.purchasesArr addObject:purchase];
        }
        
        NSArray *sortedArray = [self.purchasesArr sortedArrayUsingComparator:^NSComparisonResult(PurchaseManager *p1, PurchaseManager *p2){
            return [p2.date compare:p1.date];
        }];
        
        self.purchasesArr = [sortedArray mutableCopy];
    }
    
    return self;
}

@end
