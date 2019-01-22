//
//  BBDateManager.m
//  BBDate
//
//  Created by 程肖斌 on 2019/1/21.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "BBDateManager.h"

#define BBcountLimit   8
#define BBlocaleID     @"zh_CN"
#define BBtimeZoneName @"Asia/Shanghai"

@interface BBDateManager()
@property(nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, strong) NSCache    *cache;
@end

@implementation BBDateManager

//单例
+ (BBDateManager *)sharedManager{
    static BBDateManager *manager = nil;
    static dispatch_once_t once_t = 0;
    dispatch_once(&once_t, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (instancetype)init{
    if([super init]){
        //公历/国际历
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        //设置区域
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:BBlocaleID];
        [_calendar setLocale:locale];
        //设置时区
        NSTimeZone *zone = [NSTimeZone timeZoneWithName:BBtimeZoneName];
        [_calendar setTimeZone:zone];
        //设置星期数
        [_calendar setFirstWeekday:1];
        
        _cache = [[NSCache alloc]init];
        _cache.countLimit = BBcountLimit;
    }
    return self;
}

- (NSInteger)weekFromDate:(NSDate *)date{
    NSDateComponents *component = [_calendar components:NSCalendarUnitWeekday
                                               fromDate:date];
    NSInteger week = component.weekday-1;
    return week ? week : 7;
}

- (NSString *)stringFromDate:(NSDate *)date
                        type:(NSCalendarUnit)type{
    NSDateComponents *component = [_calendar components:type fromDate:date];
    NSMutableString *mut = [NSMutableString string];
    if(type & NSCalendarUnitYear){
        [mut appendString:[NSString stringWithFormat:@"%04d年",(int)component.year]];
    }
    if(type & NSCalendarUnitMonth){
        [mut appendString:[NSString stringWithFormat:@"%02d月",(int)component.month]];
    }
    if(type & NSCalendarUnitDay){
        [mut appendString:[NSString stringWithFormat:@"%02d日",(int)component.day]];
    }
    if(type & NSCalendarUnitHour){
        [mut appendString:[NSString stringWithFormat:@" %02d时",(int)component.hour]];
    }
    if(type & NSCalendarUnitMinute){
        [mut appendString:[NSString stringWithFormat:@"%02d分",(int)component.minute]];
    }
    if(type & NSCalendarUnitSecond){
        [mut appendString:[NSString stringWithFormat:@"%02d秒",(int)component.second]];
    }
    return mut;
}

- (NSString *)stringFromDate:(NSDate *)date
                        type:(NSCalendarUnit)type
                         sep:(NSString *)sep{
    NSDateComponents *component = [_calendar components:type fromDate:date];
    NSMutableArray *result = [NSMutableArray array];
    if(type & NSCalendarUnitYear){
        [result addObject:[NSString stringWithFormat:@"%04d",(int)component.year]];
    }
    if(type & NSCalendarUnitMonth){
        [result addObject:[NSString stringWithFormat:@"%02d",(int)component.month]];
    }
    if(type & NSCalendarUnitDay){
        [result addObject:[NSString stringWithFormat:@"%02d",(int)component.day]];
    }
    if(type & NSCalendarUnitHour){
        [result addObject:[NSString stringWithFormat:@"%02d",(int)component.hour]];
    }
    if(type & NSCalendarUnitMinute){
        [result addObject:[NSString stringWithFormat:@"%02d",(int)component.minute]];
    }
    if(type & NSCalendarUnitSecond){
        [result addObject:[NSString stringWithFormat:@"%02d",(int)component.second]];
    }
    return [result componentsJoinedByString:sep];
}

- (NSString *)stringFromDate:(NSDate *)date
                      format:(NSString *)format{
    NSDateFormatter *dateFormatter = [self dateFormatterFromFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)dateFormString:(NSString *)string
                    format:(NSString *)format{
    NSDateFormatter *dateFormatter = [self dateFormatterFromFormat:format];
    if(!string){return nil;}//format是手动输入，必须有正确值，string可能是外界传入，通过if判断
    return [dateFormatter dateFromString:string];
}

- (NSDateFormatter *)dateFormatterFromFormat:(NSString *)format{
    NSAssert(format, @"格式化字符串format不能为空");
    NSDateFormatter *dateFormatter = [_cache objectForKey:format];
    if(!dateFormatter){
        dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = format;
        dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:BBtimeZoneName];
        dateFormatter.locale   = [NSLocale localeWithLocaleIdentifier:BBlocaleID];
        [_cache setObject:dateFormatter forKey:format];
    }
    return dateFormatter;
}

- (void)parserDate:(NSDate *)date
              year:(NSInteger *)year
             month:(NSInteger *)month
               day:(NSInteger *)day{
    NSDateComponents *component = [_calendar components:Unit(BBCalendarUnitYMD)
                                               fromDate:date];
    *year  = component.year;
    *month = component.month;
    *day   = component.day;
}

- (void)parserDate:(NSDate *)date
              hour:(NSInteger *)hour
               min:(NSInteger *)min
               sec:(NSInteger *)sec{
    NSDateComponents *component = [_calendar components:Unit(BBCalendarUnitHMS)
                                               fromDate:date];
    *hour = component.hour;
    *min  = component.minute;
    *sec  = component.second;
}

- (NSInteger)days:(NSInteger)year
            month:(NSInteger)month{
    if(month == 4 || month == 6 || month == 9 || month == 11){return 30;}
    if(month != 2)   {return 31;}
    if(!(year % 400)){return 29;}
    if(year % 4)     {return 28;}
    if(!(year % 100)){return 28;}
    return 29;
}

- (NSInteger)days:(NSDate *)date{
    NSRange range = [_calendar rangeOfUnit:NSCalendarUnitDay
                                    inUnit:NSCalendarUnitMonth
                                   forDate:date];
    return range.length;
}

- (int64_t)unixFromYear:(NSInteger)year
                  month:(NSInteger)month
                    day:(NSInteger)day{
    return [self unixFromYear:year
                        month:month
                          day:day
                         hour:0
                          min:0
                          sec:0];
}

- (int64_t)unixFromYear:(NSInteger)year
                  month:(NSInteger)month
                    day:(NSInteger)day
                   hour:(NSInteger)hour
                    min:(NSInteger)min
                    sec:(NSInteger)sec{
    NSDateComponents *component = [[NSDateComponents alloc]init];
    component.year  = year;
    component.month = month;
    component.day   = day;
    component.hour  = hour;
    component.minute = min;
    component.second = sec;
    NSDate *date = [_calendar dateFromComponents:component];
    return [date timeIntervalSince1970];
}

@end
