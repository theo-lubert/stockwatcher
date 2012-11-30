//
//  SWGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWGraph.h"

@implementation SWGraph


#pragma mark -
#pragma mark Initialization methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
#if TARGET_OS_IPHONE
        [self setBackgroundColor:[SWColor clearColor]];
#endif
        [self setColor:nil];
    }
    return (self);
}

- (SWColor *)color {
    if (_color == nil) {
        _color = [SWColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
    }
    return (_color);
}


#pragma mark -
#pragma mark Drawing methods

- (void)drawRect:(NSRect)rect {
    context = [self getGraphicContext];
#if TARGET_OS_IPHONE
    CGContextClearRect(context, rect);
    CGContextScaleCTM(context, 1, -1);
#endif
}

@end
