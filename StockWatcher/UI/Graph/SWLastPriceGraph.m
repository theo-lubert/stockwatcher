//
//  SWLastPriceGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 11/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWLastPriceGraph.h"

@implementation SWLastPriceGraph


#pragma mark -
#pragma mark Drawing methods

- (void)drawPrice:(PriceData *)price withOffset:(CGFloat)offset withStep:(CGFloat)s withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    CGPathMoveToPoint(path, NULL, offset, (price->lastClose * self.frame.size.height));
    CGPathAddLineToPoint(path, NULL, (offset + s), (price->lastClose * self.frame.size.height));
    
}

- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect {
    CGContextSetLineWidth(context, 1);
    CGFloat dashArray[] = {5,2};
    CGContextSetLineDash(context, 0, dashArray, 2);
    CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
