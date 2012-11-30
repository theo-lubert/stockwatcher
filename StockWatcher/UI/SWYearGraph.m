//
//  SWYearGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/12/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWYearGraph.h"

@implementation SWYearGraph

- (NSUInteger)numberOfValueOnScreen {
    return (250);
}

- (NSUInteger)numberOfValue {
    return (1250);
}

- (void)drawDay:(NSDictionary *)day atIndex:(int)i inRect:(CGRect)rect {
    [self drawVerticalLineAtX:(i * step) withColor:[SWColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.05] inRect:rect];
}

@end
