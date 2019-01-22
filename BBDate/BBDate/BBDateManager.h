//
//  BBDateManager.h
//  BBDate
//
//  Created by 程肖斌 on 2019/1/21.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BBCalendarUnit) {
    BBCalendarUnitYM = NSCalendarUnitYear  | NSCalendarUnitMonth,
    BBCalendarUnitMD = NSCalendarUnitMonth | NSCalendarUnitDay,
    BBCalendarUnitHM = NSCalendarUnitHour  | NSCalendarUnitMinute,
    BBCalendarUnitMS = NSCalendarUnitMinute| NSCalendarUnitSecond,
    BBCalendarUnitYMD = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay,
    BBCalendarUnitHMS = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond,
    BBCalendarUnitWhole = 0 | NSCalendarUnitYear
                            | NSCalendarUnitMonth
                            | NSCalendarUnitDay
                            | NSCalendarUnitHour
                            | NSCalendarUnitMinute
                            | NSCalendarUnitSecond
};

//将BBCalendarUnit转成NSCalendarUnit
static inline NSCalendarUnit Unit(BBCalendarUnit unit){return (NSCalendarUnit)unit;}

@interface BBDateManager : NSObject

//单例
+ (BBDateManager *)sharedManager;

/*
    获取date是周几,周一对应1，周二对应2，以此类推
*/
- (NSInteger)weekFromDate:(NSDate *)date;

/*
    获取日期，xxxx年xx月xx日xx时xx分xx秒格式,根据传入的type取值
*/
- (NSString *)stringFromDate:(NSDate *)date
                        type:(NSCalendarUnit)type;

/*
    获取日期，xxxx-xx-xx xx-xx-xx类似格式,分割根据sep来
*/
- (NSString *)stringFromDate:(NSDate *)date
                        type:(NSCalendarUnit)type
                         sep:(NSString *)sep;

/*
    获取任意格式的日期字符串，根据format进行格式化
*/
- (NSString *)stringFromDate:(NSDate *)date
                      format:(NSString *)format;

/*
    从任意字符串获取date，根据format进行格式化
*/
- (NSDate *)dateFormString:(NSString *)string
                    format:(NSString *)format;

/*
    获取date的年、月、日对应的值
*/
- (void)parserDate:(NSDate *)date
              year:(NSInteger *)year
             month:(NSInteger *)month
               day:(NSInteger *)day;

/*
    获取date的时、分、秒对应的值
*/
- (void)parserDate:(NSDate *)date
              hour:(NSInteger *)hour
               min:(NSInteger *)min
               sec:(NSInteger *)sec;

/*
    获取某年某月有多少天
*/
- (NSInteger)days:(NSInteger)year
            month:(NSInteger)month;

/*
    获取date对应的月份有多少天
*/
- (NSInteger)days:(NSDate *)date;

/*
    根据年、月、日获取unix时间戳，时、分、秒为0
*/
- (int64_t)unixFromYear:(NSInteger)year
                  month:(NSInteger)month
                    day:(NSInteger)day;

/*
    根据年、月、日、时、分、秒获取到unix时间戳
*/
- (int64_t)unixFromYear:(NSInteger)year
                  month:(NSInteger)month
                    day:(NSInteger)day
                   hour:(NSInteger)hour
                    min:(NSInteger)min
                    sec:(NSInteger)sec;

@end
