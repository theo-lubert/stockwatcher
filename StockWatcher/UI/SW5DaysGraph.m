//
//  SW5DaysGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/12/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SW5DaysGraph.h"
#import "NSArray+EasyFetch.h"

@implementation SW5DaysGraph

- (NSUInteger)numberOfValueOnScreen {
    return (5);
}

- (NSUInteger)numberOfValue {
    return (10);//25);
}

@end
