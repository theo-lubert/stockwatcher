//
//  NSArray+EasyFetch.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/8/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (EasyFetch)

@property (nonatomic, readonly) id  first;
@property (nonatomic, readonly) id  last;

- (void)each:(void (^)(id obj))block;
- (void)eachWithIndex:(void (^)(id obj, int idx))block;

@end
