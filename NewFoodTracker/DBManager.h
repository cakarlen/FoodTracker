//
//  DBManager.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Helper.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

-(NSArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
