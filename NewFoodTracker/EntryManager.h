//
//  EntryManager.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/15/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PurchaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntryManager : NSObject

@property (nonatomic, strong) NSNumber *weekNumber;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSMutableArray *purchasesArr;

- (instancetype)initWithWeek:(NSNumber *)week withDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
