//
//  SWBarGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 9/4/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWBarGraph.h"

@implementation SWBarGraph


#pragma mark -
#pragma mark Drawing methods

- (void)drawPrice:(PriceData *)price withOffset:(CGFloat)offset withStep:(CGFloat)s withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    CGFloat middle = offset + (s / 2.0);
    
    CGPathMoveToPoint(path, NULL, middle, (price->low * self.frame.size.height));
    CGPathAddLineToPoint(path, NULL, middle, (price->high * self.frame.size.height));
    
    CGPathMoveToPoint(path, NULL, (middle - (MIN(kBarMaxWidth, s) * 0.4)), (price->open * self.frame.size.height));
    CGPathAddLineToPoint(path, NULL, middle, (price->open * self.frame.size.height));
    
    CGPathMoveToPoint(path, NULL, middle, (price->close * self.frame.size.height));
    CGPathAddLineToPoint(path, NULL, (middle + (MIN(kBarMaxWidth, s) * 0.4)), (price->close * self.frame.size.height));
}

@end
