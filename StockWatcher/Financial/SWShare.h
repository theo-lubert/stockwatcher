//
//  SWSymbol.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/6/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "YFStockSymbol.h"
#import "YFStockSymbolSearch.h"

#define kSWShareFinacialDataUpdated @"kSWShareFinacialDataUpdated"


typedef struct {
    NSInteger day;
    NSInteger intra;
}   DayIndex;

@protocol SWShareSearchDelegate <YFStockSymbolSearchDelegate>

@end

@interface SWShare : YFStockSymbol {
    NSMutableDictionary     *financialData;
    NSArray                 *daysArray;
    NSTimer                 *updateTimer;
}

+ (SWShare *)shareWithSymbol:(NSString *)sym;
+ (NSDateFormatter *)csvDateFormatter;
+ (NSDateFormatter *)csvIntraDayDateFormatter;

+ (NSArray *)find:(NSString *)sym;
+ (void)find:(NSString *)sym withDelegate:(id<SWShareSearchDelegate>)delegate;


- (void)askDataForDays:(NSInteger)days;
- (void)askForIntraDayDataWithRange:(NSInteger)range;
- (void)askFor5Days;
- (void)askFor1Week;
- (void)askFor1Month;
- (void)askFor3Months;
- (void)askFor6Months;
- (void)askFor1Year;
- (void)askFor5Years;

- (NSInteger)countDays;
- (NSDictionary *)dataForDay:(NSInteger)day;

@end
