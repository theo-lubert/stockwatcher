//
//  NSArray+EasyFetch.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/8/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "NSArray+EasyFetch.h"

@implementation NSArray (EasyFetch)

- (id)first {
    if (self.count > 0) {
        return [self objectAtIndex:0];
    }
    return (nil);
}

- (id)last {
    return [self lastObject];
}

- (void)each:(void (^)(id obj))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)eachWithIndex:(void (^)(id object, int index))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, (int)idx);
    }];
}

@end
