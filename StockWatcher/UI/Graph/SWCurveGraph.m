//
//  SWCurveGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWCurveGraph.h"

@implementation SWCurveGraph


#pragma mark -
#pragma mark Drawing methods

- (void)drawValue:(CGFloat)v withOffset:(CGFloat)offset withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    if (CGPathIsEmpty(path)) {
        CGPathMoveToPoint(path, NULL, offset, (v * self.frame.size.height));
    } else {
        CGPathAddLineToPoint(path, NULL, offset, (v * self.frame.size.height));
    }
}

- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect {
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    if ([self.dataSource respondsToSelector:@selector(numberOfValueInGraph:)]) {
        CGMutablePathRef path = CGPathCreateMutable();
        for (NSInteger i=0, k=[self.dataSource numberOfValueInGraph:self]; i<k; i++) {
            CGFloat value = [self.dataSource graph:self valueAtIndex:i];
            if (value != kUnvalidValue) {
                CGFloat offset = [self.dataSource graph:self offsetAtIndex:i];
                if ((CGPathIsEmpty(path))
                    || (CGRectIntersectsRect(rect, CGRectMake(CGPathGetCurrentPoint(path).x, 0, offset, self.frame.size.height)))) {
                    [self drawValue:value
                         withOffset:offset
                           withPath:path
                             inRect:rect];
                }
            }
        }
        if (!CGPathIsEmpty(path)) {
            [self drawPath:path withColor:self.color inRect:rect];
        }
        CGPathRelease(path);
    }
}

@end
