//
//  DBManager.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/10/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import "DBManager.h"

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;


-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(void)copyDatabaseIntoDocumentsDirectory;

@end

@implementation DBManager

- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

- (void)copyDatabaseIntoDocumentsDirectory{
    sqlite3 *sqlite3Database;
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
//        // The database file does not exist in the documents directory, so copy it from the main bundle now.
//        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
//        NSError *error;
//        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
//
//        // Check if any error occurred during copying and display it.
//        if (error != nil) {
//            DLog(@"%@", [error localizedDescription]);
//        }
//
#if DEBUG
        DLog(@"Database does not exist");
#endif
        const char *dbpath = [destinationPath UTF8String];

        if (sqlite3_open(dbpath, &sqlite3Database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS FOOD (ID INTEGER PRIMARY KEY AUTOINCREMENT, PLACE TEXT, PRICE FLOAT, DATE TEXT)";

            if (sqlite3_exec(sqlite3Database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                DLog(@"Failed to create the table\n");
            }
            sqlite3_close(sqlite3Database);
#if DEBUG
            DLog(@"Created database at %@", destinationPath);
#endif
        } else {
            DLog(@"Failed to open/create the database\n");
        }
    }
}

- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable {
    NSMutableDictionary *foodDict = [[NSMutableDictionary alloc] init];
    [foodDict setValue:[NSNumber numberWithInt:5] forKey:@"age"];
    
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
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
        self.arrColumnNames = nil;
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
            if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Declare an array to keep the data for each fetched row.
#if DEBUG
                DLog(@"Marked executable");
#endif
                NSMutableDictionary *arrDataRow;
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableDictionary alloc] init];
                    
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
#if DEBUG
                    DLog(@"Got total columns: %d", totalColumns);
#endif
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (characters).
                        char *dbColumnText = (char *)sqlite3_column_text(compiledStatement, i);
                        char *dbColumnName = (char *)sqlite3_column_name(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbColumnText != NULL) {
                            // Convert the characters to string.
//                            [arrDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
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
            }
            else {
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
        }
        else {
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

-(NSArray *)loadDataFromDB:(NSString *)query{
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}

-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

@end
