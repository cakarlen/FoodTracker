//
//  DBManager.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import "DBManager.h"

@interface DBManager()

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) NSString *currentDB;

- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable forDatabase:(NSString *)database;

@end

@implementation DBManager

- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename {
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        
        [self createNewDatabase:dbFilename];
    }
    return self;
}

- (void)createNewDatabase:(NSString *)database {
    sqlite3 *newDatabase;
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:database];
    
    if (!([[NSFileManager defaultManager] fileExistsAtPath:destinationPath])) {
#if DEBUG
        DLog(@"New database does not exist");
#endif
        const char *dbPath = [destinationPath UTF8String];
        
        // Entry database
        if (sqlite3_open(dbPath, &newDatabase) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS FOOD (ID INTEGER PRIMARY KEY AUTOINCREMENT, PLACE TEXT, PRICE FLOAT, DATE TEXT)";
            
            if (sqlite3_exec(newDatabase, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                DLog(@"Failed to create the table\n");
            }
            
            sqlite3_close(newDatabase);
#if DEBUG
            DLog(@"Created entry database at %@", destinationPath);
#endif
        } else {
            DLog(@"Failed to open/create the entry database file\n");
        }
    }
}

- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable forDatabase:(NSString *)database {
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    if ([database isEqualToString:@"food"]) {
        // Set the database file path.
        NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
        
        // Initialize the results array.
        if (self.arrResults != nil) {
            [self.arrResults removeAllObjects];
            self.arrResults = nil;
        }
        self.arrResults = [[NSMutableArray alloc] init];
        
        // Initialize the column names array.
        if (self.arrColumnNames != nil) {
            [self.arrColumnNames removeAllObjects];
//            self.arrColumnNames = nil;
        }
        self.arrColumnNames = [[NSMutableArray alloc] init];
        
        
        // Open the database.
        BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
        if(openDatabaseResult == SQLITE_OK) {
#if DEBUG
            DLog(@"Database found");
#endif
            
            // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
            sqlite3_stmt *compiledStatement;
            
            // Load all data from database to memory.
            BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
            if(prepareStatementResult == SQLITE_OK) {
#if DEBUG
                DLog(@"Database opened");
#endif
                // Check if the query is non-executable.
                if (!queryExecutable) {
                    // In this case data must be loaded from the database.
                    
                    // Declare an array to keep the data for each fetched row.
#if DEBUG
                    DLog(@"Marked executable");
#endif
                    NSMutableDictionary *arrDataRow;
                    
                    // Loop through the results and add them to the results array row by row.
                    while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        // Initialize the mutable array that will contain the data of a fetched row.
                        arrDataRow = [[NSMutableDictionary alloc] init];
                        
                        // Get the total number of columns.
                        int totalColumns = sqlite3_column_count(compiledStatement);
#if DEBUG
                        DLog(@"Got total columns: %d", totalColumns);
#endif
                        
                        // Go through all columns and fetch each column data.
                        for (int i=0; i<totalColumns; i++) {
                            // Convert the column data to text (characters).
                            char *dbColumnText = (char *)sqlite3_column_text(compiledStatement, i);
                            char *dbColumnName = (char *)sqlite3_column_name(compiledStatement, i);
                            
                            // If there are contents in the currenct column (field) then add them to the current row array.
                            if (dbColumnText != NULL) {
                                // Convert the characters to string.
                                [arrDataRow setValue:[NSString stringWithUTF8String:dbColumnText] forKey:[NSString stringWithUTF8String:dbColumnName]];
                            }
                            
                            // Keep the current column name.
                            if (self.arrColumnNames.count != totalColumns) {
                                dbColumnName = (char *)sqlite3_column_name(compiledStatement, i);
                                [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbColumnName]];
                            }
                        }
                        
#if DEBUG
                        DLog(@"arrColumnNames is: %@", [self arrColumnNames]);
                        DLog(@"arrDataRow is: %@", arrDataRow);
#endif
                        
                        // Store each fetched data row in the results array, but first check if there is actually data.
                        if (arrDataRow.count > 0) {
                            [self.arrResults addObject:arrDataRow];
                            //                        [self.arrResults setValue:arrDataRow forKey:@"age"];
#if DEBUG
                            DLog(@"arrResults is: %@", self.arrResults);
#endif
                        }
                    }
                } else {
                    // This is the case of an executable query (insert, update, ...).
                    
#if DEBUG
                    DLog(@"Not marked executable");
#endif
                    // Execute the query.
                    if (sqlite3_step(compiledStatement)) {
                        // Keep the affected rows.
                        self.affectedRows = sqlite3_changes(sqlite3Database);
                        
                        // Keep the last inserted row ID.
                        self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                    }
                    else {
                        // If could not execute the query show the error message on the debugger.
                        DLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                    }
                }
            } else {
                // In the database cannot be opened then show the error message on the debugger.
#if DEBUG
                DLog(@"%s", sqlite3_errmsg(sqlite3Database));
#endif
                
            }
            
            // Release the compiled statement from memory.
            sqlite3_finalize(compiledStatement);
            
        }
    } else if ([database isEqualToString:@"current"]) {
        NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.currentDB];
        
        // Initialize the results array.
        if (self.arrResults != nil) {
            [self.arrResults removeAllObjects];
            self.arrResults = nil;
        }
        self.arrResults = [[NSMutableArray alloc] init];
        
        // Initialize the column names array.
        if (self.arrColumnNames != nil) {
            [self.arrColumnNames removeAllObjects];
//            self.arrColumnNames = nil;
        }
        self.arrColumnNames = [[NSMutableArray alloc] init];
        
        
        // Open the database.
        BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
        if(openDatabaseResult == SQLITE_OK) {
#if DEBUG
            DLog(@"Database found");
#endif
            
            // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
            sqlite3_stmt *compiledStatement;
            
            // Load all data from database to memory.
            BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
            if(prepareStatementResult == SQLITE_OK) {
#if DEBUG
                DLog(@"Database opened");
#endif
                // Check if the query is non-executable.
                if (!queryExecutable) {
                    // In this case data must be loaded from the database.
                    
                    // Declare an array to keep the data for each fetched row.
#if DEBUG
                    DLog(@"Marked executable");
#endif
                    NSMutableDictionary *arrDataRow;
                    
                    // Loop through the results and add them to the results array row by row.
                    while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        // Initialize the mutable array that will contain the data of a fetched row.
                        arrDataRow = [[NSMutableDictionary alloc] init];
                        
                        // Get the total number of columns.
                        int totalColumns = sqlite3_column_count(compiledStatement);
#if DEBUG
                        DLog(@"Got total columns: %d", totalColumns);
#endif
                        
                        // Go through all columns and fetch each column data.
                        for (int i=0; i<totalColumns; i++) {
                            // Convert the column data to text (characters).
                            char *dbColumnText = (char *)sqlite3_column_text(compiledStatement, i);
                            char *dbColumnName = (char *)sqlite3_column_name(compiledStatement, i);
                            
                            // If there are contents in the currenct column (field) then add them to the current row array.
                            if (dbColumnText != NULL) {
                                // Convert the characters to string.
                                [arrDataRow setValue:[NSString stringWithUTF8String:dbColumnText] forKey:[NSString stringWithUTF8String:dbColumnName]];
                            }
                            
                            // Keep the current column name.
                            if (self.arrColumnNames.count != totalColumns) {
                                dbColumnName = (char *)sqlite3_column_name(compiledStatement, i);
                                [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbColumnName]];
                            }
                        }
                        
#if DEBUG
                        DLog(@"arrColumnNames is: %@", [self arrColumnNames]);
                        DLog(@"arrDataRow is: %@", arrDataRow);
#endif
                        
                        // Store each fetched data row in the results array, but first check if there is actually data.
                        if (arrDataRow.count > 0) {
                            [self.arrResults addObject:arrDataRow];
                            //                        [self.arrResults setValue:arrDataRow forKey:@"age"];
#if DEBUG
                            DLog(@"arrResults is: %@", self.arrResults);
#endif
                        }
                    }
                } else {
                    // This is the case of an executable query (insert, update, ...).
                    
#if DEBUG
                    DLog(@"Not marked executable");
#endif
                    // Execute the query.
                    if (sqlite3_step(compiledStatement)) {
                        // Keep the affected rows.
                        self.affectedRows = sqlite3_changes(sqlite3Database);
                        
                        // Keep the last inserted row ID.
                        self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                    }
                    else {
                        // If could not execute the query show the error message on the debugger.
                        DLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                    }
                }
            } else {
                // In the database cannot be opened then show the error message on the debugger.
#if DEBUG
                DLog(@"%s", sqlite3_errmsg(sqlite3Database));
#endif
                
            }
            
            // Release the compiled statement from memory.
            sqlite3_finalize(compiledStatement);
        }
        
        // Close the database.
        sqlite3_close(sqlite3Database);
    }
}

- (NSArray *)loadDataFromDB:(NSString *)query forDatabase:(NSString *)database {
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] isQueryExecutable:NO forDatabase:database];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}

- (void)executeQuery:(NSString *)query forDatabase:(NSString *)database {
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES forDatabase:database];
}

@end
