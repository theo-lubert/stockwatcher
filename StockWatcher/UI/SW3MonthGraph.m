//
//  SW3MonthGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/9/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SW3MonthGraph.h"

@implementation SW3MonthGraph

- (NSUInteger)numberOfValueOnScreen {
    return (90);
}

- (NSUInteger)numberOfValue {
    return (356);
}

- (void)drawDay:(NSDictionary *)day atIndex:(int)i inRect:(CGRect)rect {
    [self drawVerticalLineAtX:(i * step) withColor:[SWColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.05] inRect:rect];
}

@end
