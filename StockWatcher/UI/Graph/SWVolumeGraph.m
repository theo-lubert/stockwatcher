//
//  SWVolumeGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/25/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWVolumeGraph.h"

@implementation SWVolumeGraph


#pragma mark -
#pragma mark Drawing methods

- (void)drawVolume:(CGFloat)v withStep:(CGFloat)s inRect:(CGRect)rect {
    CGContextSetRGBFillColor(context, [self.color redComponent], [self.color greenComponent], [self.color blueComponent], [self.color alphaComponent]);
    CGContextFillRect(context, (CGRect) {
        .origin.x = 0.1 * s,
        .origin.y = 0,
        .size.width = 0.8 * s,
        .size.height = v * self.frame.size.height
    });
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    
//    CGContextClearRect(context, rect);
//    CGContextSetFillColor(context, CGColorGetComponents([[SWColor colorWithDeviceRed:1 green:0 blue:0 alpha:0.1] CGColor]));
//    CGContextFillRect(context, rect);
    
    if ([self.dataSource respondsToSelector:@selector(numberOfValueInGraph:)]) {
        for (NSInteger i=0, k=[self.dataSource numberOfValueInGraph:self]; i<k; i++) {
            CGFloat offset = [self.dataSource graph:self offsetAtIndex:i];
            CGFloat width = [self.dataSource graph:self widthAtIndex:i];
            if (CGRectIntersectsRect(rect, CGRectMake(offset, 0, (offset + width), self.frame.size.height))) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, offset, 0);
                [self drawVolume:[self.dataSource graph:self valueAtIndex:i]
                        withStep:[self.dataSource graph:self widthAtIndex:i] inRect:rect];
                CGContextRestoreGState(context);
            }
        }
    }
}

@end
