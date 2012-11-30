//
//  SWAppDelegate.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/2/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWAppDelegate.h"
#import "NSArray+EasyFetch.h"
#import "SWColor.h"
#import "SWShare.h"

@implementation SWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)awakeFromNib {
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];
	[[DDTTYLogger sharedInstance] setForegroundColor:[SWColor redColor] backgroundColor:nil forTag:RedTag];
	[[DDTTYLogger sharedInstance] setForegroundColor:[SWColor greenColor] backgroundColor:nil forTag:GreenTag];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_statusMenu];
    [_statusItem setTitle:@"StockWatcher"];
    
    [_dayItem setView:_dayScroll];
    [_weekItem setView:_weekScroll];
    [_monthItem setView:_monthScroll];
    [_yearItem setView:_yearScroll];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showData:) name:kSWShareFinacialDataUpdated object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:)
//                                                 name:kDataNeedsUpdate object:nil];
    
    share = [SWShare shareWithSymbol:@"AAPL"];
    [share askFor5Years];
    [self performSelectorInBackground:@selector(updateData) withObject:nil];
}

- (void)displayDayDescription:(NSDictionary *)d withLast:(float)last {
    if ([[d objectForKey:@"close"] floatValue] > last) {
        DDLogGreen(@"%@: (%.2f | %.2f) - %.2f",
                   [d objectForKey:@"date"],
                   [[d objectForKey:@"low"] floatValue],
                   [[d objectForKey:@"high"] floatValue],
                   [[d objectForKey:@"close"] floatValue]);
    } else if ([[d objectForKey:@"close"] floatValue] < last) {
        DDLogRed(@"%@: (%.2f | %.2f) - %.2f",
                 [d objectForKey:@"date"],
                 [[d objectForKey:@"low"] floatValue],
                 [[d objectForKey:@"high"] floatValue],
                 [[d objectForKey:@"close"] floatValue]);
    } else {
        DDLogInfo(@"%@: (%.2f | %.2f) - %.2f",
                  [d objectForKey:@"date"],
                  [[d objectForKey:@"low"] floatValue],
                  [[d objectForKey:@"high"] floatValue],
                  [[d objectForKey:@"close"] floatValue]);
    }
}

- (void)displayIntraDayDescription:(NSDictionary *)d withLast:(float)last {
    if ([[d objectForKey:@"close"] floatValue] > last) {
        DDLogGreen(@"%@: (%.2f | %.2f) - %.2f (IntraDay)",
                   [d objectForKey:@"date"],
                   [[d objectForKey:@"low"] floatValue],
                   [[d objectForKey:@"high"] floatValue],
                   [[d objectForKey:@"close"] floatValue]);
    } else if ([[d objectForKey:@"Close"] floatValue] < last) {
        DDLogRed(@"%@: (%.2f | %.2f) - %.2f (IntraDay)",
                 [d objectForKey:@"date"],
                 [[d objectForKey:@"low"] floatValue],
                 [[d objectForKey:@"high"] floatValue],
                 [[d objectForKey:@"close"] floatValue]);
    } else {
        DDLogInfo(@"%@: (%.2f | %.2f) - %.2f (IntraDay)",
                  [d objectForKey:@"date"],
                  [[d objectForKey:@"low"] floatValue],
                  [[d objectForKey:@"high"] floatValue],
                  [[d objectForKey:@"close"] floatValue]);
    }
}

- (void)updateData {
    while (1) {
        [share askForIntraDayDataWithRange:5];
        sleep(30);
    }
}

- (void)showData:(NSNotification *)notif {
    SWShare *s = [[notif userInfo] objectForKey:@"share"];
    DDLogCVerbose(@"%@:", s.symbol);
    NSDateFormatter *df = [SWShare csvDateFormatter];
    float last = -1;
    for (NSInteger i=355; i>=0; i--) {
        NSDictionary *d = [s dataForDay:i];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(-i * 86400)];
        NSString *key = [df stringFromDate:date];
        if ((d) && (last == -1)) {
            last = [[d objectForKey:@"close"] floatValue];
        } else if (d) {
            if ([d objectForKey:@"intraday"]) {
                [self displayIntraDayDescription:d withLast:last];
            } else {
                [self displayDayDescription:d withLast:last];
            }
            last = [[d objectForKey:@"close"] floatValue];
        } else {
            DDLogCInfo(@"%@: Missing data", key);
        }
    }
}

- (NSInteger)days {
    return ([share countDays]);
}

- (NSDictionary *)dayDataAtIndex:(NSUInteger)index {
    return ([share dataForDay:index]);
}


#pragma mark -
#pragma mark Action methods

- (IBAction)searchStock:(id)sender {
    NSString *search = [[_searchField stringValue] uppercaseString];
    [[SWShare find:search] each:^(SWShare *s) {
        DDLogWarn(@"%@: %@ (%@)", s.symbol, s.name, s.currency);
        if ([s.symbol isEqualToString:search]
            || [s.name isEqualToString:search]) {
            share = s;
            [share askFor5Years];
            [self performSelectorInBackground:@selector(updateData) withObject:nil];
        }
    }];
}

@end
