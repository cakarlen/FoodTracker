//
//  Helper.h
//  NewFoodTracker
//
//  Created by Chase Karlen on 11/12/19.
//  Copyright © 2019 Chase Karlen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Helper : NSObject

// Conversions
- (NSString *)convertDateToString:(UIDatePicker *)dateField;
- (NSDate *)convertStringToDate:(NSString *)stringToConvert;
- (NSNumber *)numberFromString:(NSString *)string;
- (NSString *)stringFromNumber:(NSNumber *)num;
- (NSString *)stringByFormattingString:(NSString *)string toPrecision:(NSInteger)precision;

// Convenience
- (UIAlertController *)createAlertWithTitle:(NSString *)title withMessage:(NSString *)message withActions:(NSArray <UIAlertAction *> *)actions;
- (BOOL)doesfileExist:(NSString *)file;

@end

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif


NS_ASSUME_NONNULL_END
