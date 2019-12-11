//
//  PurchaseManager.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/19/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import "PurchaseManager.h"

@implementation PurchaseManager

- (instancetype)initWithID:(NSNumber *)idNum andPlace:(NSString *)place andPrice:(NSNumber *)price atDate:(NSString *)date {
    self = [super init];
    if (self) {
        _idNum = idNum;
        _place = place;
        _price = price;
        _date = date;
    }
    
    return self;
}

@end
