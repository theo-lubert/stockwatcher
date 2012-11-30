//
//  SWSymbol.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/6/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWShare.h"
#import "NSArray+EasyFetch.h"
#import "AFNetworking.h"

@implementation SWShare


#pragma mark -
#pragma mark Class methods

+ (SWShare *)shareWithSymbol:(NSString *)sym {
    SWShare *share = [SWShare new];
    share.symbol = sym;
    return (share);
}

+ (SWShare *)shareWithYFStockSymbol:(YFStockSymbol *)sym {
    SWShare *share = [SWShare new];
    share.symbol = sym.symbol;
    share.name = sym.name;
    share.currency = sym.currency;
    return (share);
}

+ (NSArray *)find:(NSString *)sym {
    YFStockSymbolSearch *symbolSearch = [YFStockSymbolSearch symbolSearchWithDelegate:nil];
    symbolSearch.synchronousSearch = YES;
    [symbolSearch findSymbols:sym];
    NSMutableArray *array = [NSMutableArray new];
    for (YFStockSymbol *symbol in symbolSearch.symbols) {
        [array addObject:[SWShare shareWithYFStockSymbol:symbol]];
    }
    return ([NSArray arrayWithArray:array]);
}

+ (void)find:(NSString *)sym withDelegate:(id<SWShareSearchDelegate>)delegate {
    YFStockSymbolSearch *symbolSearch = [YFStockSymbolSearch symbolSearchWithDelegate:delegate];
    [symbolSearch findSymbols:sym];
}

+ (void)symbolSearchDidFinish:(YFStockSymbolSearch *)symbolFinder {
    for (YFStockSymbol *symbol in symbolFinder.symbols) {
        NSLog(@"Found symbol: %@", symbol.name);
    }
}

+ (void)symbolSearchDidFail:(YFStockSymbolSearch *)symbolFinder {
    NSLog(@"FAIL!");
}

+ (NSDateFormatter *)csvDateFormatter {
	static NSDateFormatter *df = nil;
    
	if ( !df ) {
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd"];
	}
	return df;
}

+ (NSDateFormatter *)csvIntraDayDateFormatter {
	static NSDateFormatter *df = nil;
    
	if ( !df ) {
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyyMMdd"];
	}
	return df;
}


#pragma mark -
#pragma mark URL related methods

+ (NSString *)URLForSymbol:(NSString *)sym withStartDate:(NSDate *)start andEndDate:(NSDate *)end {
	unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
    
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
    
	NSDateComponents *compsStart = [gregorian components:unitFlags fromDate:start];
	NSDateComponents *compsEnd	 = [gregorian components:unitFlags fromDate:end];
    
	NSString *url = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&", sym];
	url = [url stringByAppendingFormat:@"a=%d&", [compsStart month] - 1];
	url = [url stringByAppendingFormat:@"b=%d&", [compsStart day]];
	url = [url stringByAppendingFormat:@"c=%d&", [compsStart year]];
    
	url = [url stringByAppendingFormat:@"d=%d&", [compsEnd month] - 1];
	url = [url stringByAppendingFormat:@"e=%d&", [compsEnd day]];
	url = [url stringByAppendingFormat:@"f=%d&", [compsEnd year]];
	url = [url stringByAppendingString:@"g=d&"];
    
	url = [url stringByAppendingString:@"ignore=.csv"];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DDLogVerbose(@"URL: %@", url);
	return url;
}

+ (NSString *)intraDayURLForSymbol:(NSString *)sym withRange:(NSInteger)range {
	NSString *url = [NSString stringWithFormat:@"http://chartapi.finance.yahoo.com/instrument/1.0/%@/chartdata;type=quote;range=%dd/csv/", sym, MAX(1, MIN(5, range))];
    DDLogVerbose(@"URL: %@", url);
	return url;
}

- (NSString *)URLWithStartDate:(NSDate *)start andEndDate:(NSDate *)end {
    return ([SWShare URLForSymbol:self.symbol withStartDate:start andEndDate:end]);
}

- (NSString *)intraDayURLWithRange:(NSInteger)range {
    return ([SWShare intraDayURLForSymbol:self.symbol withRange:range]);
}


#pragma mark -
#pragma mark Description methods

- (NSString *)debugDescription {
    return ([NSString stringWithFormat:@"<%@:%p> %@, %@", self.class, self, self.symbol, self.name]);
}

- (NSString *)description {
    return ([NSString stringWithFormat:@"%@, %@", self.symbol, self.name]);
}


#pragma mark -
#pragma mark Finacial data methods

- (NSArray *)days {
    if (daysArray == nil) {
        daysArray = [[financialData allValues] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2) {
            return ([[d2 objectForKey:@"date"] compare:[d1 objectForKey:@"date"]]);
        }];
    }
    return daysArray;
}

- (NSInteger)countDays {
    return ([self days].count);
}

- (NSString *)dateForDayBefore:(NSString *)date {
    for (NSUInteger i=0, k=daysArray.count; i<(k-1); i++) {
        NSDictionary *d = [daysArray objectAtIndex:i];
        if ([[d objectForKey:@"date"] isEqualToString:date]) {
            NSDictionary *d = [daysArray objectAtIndex:(i + 1)];
            return ([d objectForKey:@"date"]);
        }
    }
    return (nil);
}

- (NSString *)dateForDayAfter:(NSString *)date {
    for (NSUInteger i=1, k=daysArray.count; i<k; i++) {
        NSDictionary *d = [daysArray objectAtIndex:i];
        if ([[d objectForKey:@"date"] isEqualToString:date]) {
            NSDictionary *d = [daysArray objectAtIndex:(i - 1)];
            return ([d objectForKey:@"date"]);
        }
    }
    return (nil);
}

- (NSDictionary *)dataForDay:(NSInteger)day {
    //    NSDateFormatter *df = [SWShare csvDateFormatter];
    //    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(-day * 86400)];
    //    return ([financialData objectForKey:[df stringFromDate:date]]);
    if ([self days].count > day) {
        return ([[self days] objectAtIndex:day]);
    }
    return (nil);
}

- (void)saveFinancialData:(NSString *)data intraday:(Boolean)intraday {
    if (intraday) {
        [self performSelectorInBackground:@selector(saveFinancialIntraDayData:) withObject:data];
    } else {
        [self performSelectorInBackground:@selector(saveFinancialData:) withObject:data];
    }
}

- (void)askForDataWithStartDate:(NSDate *)start andEndDate:(NSDate *)end {
    NSURL *url = [NSURL URLWithString:[self URLWithStartDate:start andEndDate:end]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
        [self saveFinancialData:[operation responseString] intraday:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Error: %@: unable to get financial data\nError: %@", self.symbol, error);
    }];
    [operation start];
}

- (void)askForIntraDayDataWithRange:(NSInteger)range {
    NSURL *url = [NSURL URLWithString:[self intraDayURLWithRange:range]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
        [self saveFinancialData:[operation responseString] intraday:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Error: %@: unable to get intraday data\nError: %@", self.symbol, error);
    }];
    [operation start];
}

- (void)askDataForDays:(NSInteger)days {
    [self askForDataWithStartDate:[NSDate dateWithTimeIntervalSinceNow:(-days * 86400)] andEndDate:[NSDate date]];
    [self askForIntraDayDataWithRange:days];
}

- (void)askFor5Days {
    [self askDataForDays:5];
}

- (void)askFor1Week {
    [self askDataForDays:7];
}

- (void)askFor1Month {
    [self askDataForDays:30];
}

- (void)askFor3Months {
    [self askDataForDays:90];
}

- (void)askFor6Months {
    [self askDataForDays:180];
}

- (void)askFor1Year {
    [self askDataForDays:356];
}

- (void)askFor5Years {
    [self askDataForDays:(5 * 356)];
}


#pragma mark -
#pragma mark CSV parsing methods

+ (NSDictionary *)dayWithData:(NSArray *)values keys:(NSArray *)keys {
    if (keys.count == values.count) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (int i=0; i<keys.count; i++) {
            [dict setValue:[values objectAtIndex:i]
                    forKey:[[keys objectAtIndex:i] lowercaseString]];
        }
        return (dict);
    } else if (values.count > 1) {
        DDLogError(@"Invalide CSV line:\n%@\n%@",
                   [keys componentsJoinedByString:@","],
                   [values componentsJoinedByString:@","]);
    }
    return (nil);
}

- (void)updateData:(NSDictionary *)data forDay:(NSString *)date {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[financialData objectForKey:date]];
    for (NSString *key in data.allKeys) {
        [dict setObject:[data objectForKey:key] forKey:key];
    }
    [financialData setObject:dict forKey:date];
}

- (void)computeMobileAverage:(NSUInteger)range {
    for (NSUInteger i=0, k=(daysArray.count-range); i<k; i++) {
        CGFloat sum = 0;
        for (NSUInteger j=i; j<(i+range); j++) {
            sum += [[[daysArray objectAtIndex:j] objectForKey:@"close"] floatValue];
        }
        [[daysArray objectAtIndex:i] setObject:[NSNumber numberWithFloat:(sum / (CGFloat)range)]
                                        forKey:[NSString stringWithFormat:@"mm%lu", range]];
    }
}

- (void)computeMobileAverages {
    [self days];
    [self computeMobileAverage:20];
    [self computeMobileAverage:50];
//    [self computeMobileAverage:100];
}

- (void)computeLastPrice {
    [self days];
    NSNumber *last = nil;
    for (int i=(int)(daysArray.count-1), k=0; i>=k; i--) {
        if (last) {
            [[daysArray objectAtIndex:i] setObject:last forKey:@"lastClose"];
        }
        last = [[daysArray objectAtIndex:i] objectForKey:@"close"];
    }
}

- (void)saveFinancialData:(NSString *)data {
    if (financialData == nil) {
        financialData = [NSMutableDictionary new];
    }
    
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    NSArray *keys = [[lines first] componentsSeparatedByString:@","];
    if ((keys.count == 7) && ([[keys first] isEqualToString:@"Date"])) {
        for (int i=1; i<lines.count; i++) {
            NSArray *values = [[lines objectAtIndex:i] componentsSeparatedByString:@","];
            NSDictionary *dict = [SWShare dayWithData:values keys:keys];
            if (dict && [dict objectForKey:@"date"]) {
                [self updateData:dict forDay:[dict objectForKey:@"date"]];
            }
        }
    } else {
        DDLogError(@"Invalid keys: %@", keys);
    }
    daysArray = nil;
    
    [self computeLastPrice];
    [self computeMobileAverages];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSWShareFinacialDataUpdated"
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self forKey:@"share"]];
}


#pragma mark -
#pragma mark IntraDay CSV parsing methods

+ (NSDictionary *)intraDayWithData:(NSArray *)values keys:(NSArray *)keys {
    if (keys.count == values.count) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (int i=0; i<keys.count; i++) {
            [dict setValue:[values objectAtIndex:i]
                    forKey:[[keys objectAtIndex:i] lowercaseString]];
        }
        return (dict);
    } else if (values.count > 1) {
        DDLogError(@"Invalide CSV line:\n%@\n%@",
                   [keys componentsJoinedByString:@","],
                   [values componentsJoinedByString:@","]);
    }
    return (nil);
}

- (void)addValue:(NSArray *)v toData:(NSMutableArray *)ranges withKeys:(NSArray *)keys {
    NSInteger timestamp = [[v first] integerValue];
    for (NSMutableDictionary *r in ranges) {
        if ((timestamp >= [[r objectForKey:@"openTimestamp"] integerValue])
            && (timestamp <= [[r objectForKey:@"closeTimestamp"] integerValue])) {
            NSMutableArray *values = [r objectForKey:@"intraday"];
            [values addObject:[SWShare intraDayWithData:v keys:keys]];
            [r setObject:values forKey:@"intraday"];
        }
    }
}

- (void)setIntraDay:(NSMutableDictionary *)intraDay object:(NSObject *)obj forKey:(NSString *)key {
    if (([obj isKindOfClass:[NSString class]])
        && ([[(NSString *)obj componentsSeparatedByString:@","] count] > 1)) {
        NSArray *c = [(NSString *)obj componentsSeparatedByString:@","];
        if ([key isEqualToString:@"high"]) {
            float n = MAX([[c first] floatValue], [[c last] floatValue]);
            [intraDay setObject:[NSNumber numberWithFloat:n] forKey:key];
        } else if ([key isEqualToString:@"low"]) {
            float n = MIN([[c first] floatValue], [[c last] floatValue]);
            [intraDay setObject:[NSNumber numberWithFloat:n] forKey:key];
        } else if ([key isEqualToString:@"volume"]) {
            float n = MAX([[c first] floatValue], [[c last] floatValue]);
            [intraDay setObject:[NSNumber numberWithFloat:n] forKey:@"intradayMaxVolume"];
        } else {
            [intraDay setObject:obj forKey:key];
        }
    } else {
        [intraDay setObject:obj forKey:key];
    }
}

- (NSNumber *)computeIntradayMobileAverage:(NSUInteger)range forDayIndex:(DayIndex)index {
    CGFloat sum = 0;
    @synchronized(daysArray) {
    NSArray *intraday = nil;
    for (NSUInteger j=0; j<range; j++) {
        if (index.intra < 0) {
            index.day++;
            if (index.day >= daysArray.count) {
                return (nil);
            }
            intraday = [[daysArray objectAtIndex:index.day] objectForKey:@"intraday"];
            if (intraday == nil) {
                return (nil);
            }
            index.intra = intraday.count - 1;
        } else {
            intraday = [[daysArray objectAtIndex:index.day] objectForKey:@"intraday"];
        }
        NSDictionary *tmp = [intraday objectAtIndex:index.intra];
        sum += [[tmp objectForKey:@"close"] floatValue];
        index.intra--;
    }
    }
    return ([NSNumber numberWithFloat:(sum / (CGFloat)range)]);
}

- (void)computeIntradayMobileAverage:(NSUInteger)range {
    for (NSUInteger i=0, k=daysArray.count; i<k; i++) {
        NSArray *intraday = [[daysArray objectAtIndex:i] objectForKey:@"intraday"];
        if (intraday) {
            for (NSUInteger idx=0; idx<intraday.count; idx++) {
                NSMutableDictionary *d = [intraday objectAtIndex:idx];
                DayIndex index = (DayIndex) {
                    .day = i,
                    .intra = idx
                };
                NSNumber *n = [self computeIntradayMobileAverage:range forDayIndex:index];
                if (n) {
                    [d setObject:n forKey:[NSString stringWithFormat:@"mm%lu", range]];
                }
            }
        }
    }
}

- (void)computeIntradayMobileAverages {
    [self days];
    [self computeIntradayMobileAverage:20];
    [self computeIntradayMobileAverage:50];
    [self computeIntradayMobileAverage:100];
}

- (void)computeDayValuesInDay:(NSMutableDictionary *)day {
    NSArray *intraday = [day objectForKey:@"intraday"];
    float open = [[[intraday first] objectForKey:@"open"] floatValue];
    float close = [[[intraday last] objectForKey:@"close"] floatValue];
    float low = open;
    float high = open;
    for (NSDictionary *dict in intraday) {
        low = MIN(low, [[dict objectForKey:@"low"] floatValue]);
        high = MAX(high, [[dict objectForKey:@"high"] floatValue]);
    }
    [day setObject:[NSNumber numberWithFloat:open] forKey:@"open"];
    [day setObject:[NSNumber numberWithFloat:close] forKey:@"close"];
    [day setObject:[NSNumber numberWithFloat:low] forKey:@"low"];
    [day setObject:[NSNumber numberWithFloat:high] forKey:@"high"];
}

- (void)saveFinancialIntraDayData:(NSString *)data {
    if (financialData == nil) {
        financialData = [NSMutableDictionary new];
    }
    
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    NSMutableArray *ranges = [NSMutableArray new];
    NSMutableDictionary *intraDay = [NSMutableDictionary new];
    for (int i=0; i<lines.count; i++) {
        NSArray *components = [[lines objectAtIndex:i] componentsSeparatedByString:@":"];
        if (components.count > 1) {
            NSString *key = [components first];
            if ([key isEqualToString:@"range"]) {
                NSArray *c = [[components last] componentsSeparatedByString:@","];
                NSDate *d = [[SWShare csvIntraDayDateFormatter] dateFromString:[c first]];
                NSString *date = [[SWShare csvDateFormatter] stringFromDate:d];
                NSMutableDictionary *r = [NSMutableDictionary new];
                [r setObject:date forKey:@"date"];
                [r setObject:[c objectAtIndex:1] forKey:@"openTimestamp"];
                [r setObject:[c objectAtIndex:2] forKey:@"closeTimestamp"];
                [r setObject:[NSMutableArray new] forKey:@"intraday"];
                [ranges addObject:r];
            } else if ((ranges.count <= 0) && ([key isEqualToString:@"Timestamp"])) {
                NSArray *c = [[components last] componentsSeparatedByString:@","];
                NSString *date = [[SWShare csvDateFormatter] stringFromDate:[NSDate date]];
                NSMutableDictionary *r = [NSMutableDictionary new];
                [r setObject:date forKey:@"date"];
                [r setObject:[c objectAtIndex:0] forKey:@"openTimestamp"];
                [r setObject:[c objectAtIndex:1] forKey:@"closeTimestamp"];
                [r setObject:[NSMutableArray new] forKey:@"intraday"];
                [ranges addObject:r];
            } else if (![key isEqualToString:@"close"]
                       && ![key isEqualToString:@"open"]
                       && ![key isEqualToString:@"low"]
                       && ![key isEqualToString:@"high"]) {
                [self setIntraDay:intraDay object:[components last] forKey:[key lowercaseString]];
            }
        } else {
            [self addValue:[[components first] componentsSeparatedByString:@","]
                    toData:ranges
                  withKeys:[[intraDay objectForKey:@"values"] componentsSeparatedByString:@","]];
        }
    }
    for (NSMutableDictionary *r in ranges) {
        NSString *date = [r objectForKey:@"date"];
        [intraDay setObject:[[r objectForKey:@"intraday"] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2) {
            return ([[d1 objectForKey:@"timestamp"] compare:[d2 objectForKey:@"timestamp"]]);
        }]
                     forKey:@"intraday"];
        [self computeDayValuesInDay:r];
        [self updateData:intraDay forDay:date];
        [self updateData:r forDay:date];
    }
    daysArray = nil;
    
    [self computeLastPrice];
    [self computeIntradayMobileAverages];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSWShareFinacialDataUpdated
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self forKey:@"share"]];
}



@end
