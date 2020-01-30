//
//  Helper.m
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/15/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//

#import "Helper.h"

@interface Helper()

@end

@implementation Helper

+ (id)sharedManager {
    static Helper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (NSString *)convertDateToString:(UIDatePicker *)dateField {
    NSDate *date = dateField.date;
    NSDateFormatter *_dateFormat = [[NSDateFormatter alloc]
                                    init];
    
    [_dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateText = [_dateFormat stringFromDate:date];
    
    return dateText;
}

- (NSDate *)convertStringToDate:(NSString *)stringToConvert {
    NSDateFormatter *SDF = [[NSDateFormatter alloc]
                             init];
    [SDF setDateStyle:NSDateFormatterMediumStyle];
    [SDF setDateFormat:@"MM/dd/yyyy"];
    NSDate *convertedDate = [SDF dateFromString:stringToConvert];
    
    return convertedDate;
}

- (NSNumber *)numberFromString:(NSString *)string {
    if (string.length) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:string];
    } else {
        return [NSNumber numberWithInt:0];
    }
}

- (NSString *)stringFromNumber:(NSNumber *)num {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    return [f stringFromNumber:num];
}

- (NSString *)stringByFormattingString:(NSString *)string toPrecision:(NSInteger)precision {
    NSNumber *numberValue = [self numberFromString:string];

    if ([numberValue boolValue]) {
        NSString *formatString = [NSString stringWithFormat:@"%%.%ldf", (long)precision];
        return [NSString stringWithFormat:formatString, numberValue.floatValue];
    } else {
        /* return original string */
        return string;
    }
}

- (UIAlertController *)createAlertWithTitle:(NSString *)title withMessage:(NSString *)message withActions:(NSArray <UIAlertAction *> *)actions {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *singleAction in actions) {
        [alert addAction:singleAction];
    }
    
    return alert;
}

- (BOOL)doesfileExist:(NSString *)file {
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return YES;
    } else {
        return NO;
    }
}


@end

