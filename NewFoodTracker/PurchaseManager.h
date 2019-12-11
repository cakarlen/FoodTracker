//
//  PurchaseManager.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/19/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PurchaseManager : NSObject

@property (nonatomic, assign) NSNumber *idNum;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *date;

- (instancetype)initWithID:(NSNumber *)idNum andPlace:(NSString *)place andPrice:(NSNumber *)price atDate:(NSString *)date;

@end

NS_ASSUME_NONNULL_END
