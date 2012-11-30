//
//  SWPriceGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 9/10/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWPriceGraph.h"

@implementation SWPriceGraph


#pragma mark -
#pragma mark Drawing methods

- (void)drawPrice:(PriceData *)price withOffset:(CGFloat)offset withStep:(CGFloat)s withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    // do nothing
}

- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect {
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    
//    CGContextClearRect(context, rect);
//    CGContextSetFillColor(context, CGColorGetComponents([[SWColor colorWithDeviceRed:0 green:1 blue:0 alpha:0.1] CGColor]));
//    CGContextFillRect(context, rect);
    
    if ([self.dataSource respondsToSelector:@selector(numberOfValueInGraph:)]) {
        CGMutablePathRef path = CGPathCreateMutable();
        for (NSInteger i=0, k=[self.dataSource numberOfValueInGraph:self]; i<k; i++) {
            PriceData price = [self.dataSource graph:self priceDataAtIndex:i];
            CGFloat offset = [self.dataSource graph:self offsetAtIndex:i];
            CGFloat width = [self.dataSource graph:self widthAtIndex:i];
            if ((CGPathIsEmpty(path))
                || (CGRectIntersectsRect(rect, CGRectMake(CGPathGetCurrentPoint(path).x, 0, offset, self.frame.size.height)))) {
                [self drawPrice:&price
                     withOffset:offset
                       withStep:width
                       withPath:path
                         inRect:rect];
            }
        }
        if (!CGPathIsEmpty(path)) {
            [self drawPath:path withColor:self.color inRect:rect];
        }
        CGPathRelease(path);
    }
}

@end
