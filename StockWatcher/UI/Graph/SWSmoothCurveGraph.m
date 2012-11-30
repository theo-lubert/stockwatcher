//
//  SWSmoothCurveGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWSmoothCurveGraph.h"

@implementation SWSmoothCurveGraph


#pragma mark -
#pragma mark Initialization methods

- (id)init {
    self = [super init];
    if (self) {
        self.smooth = kDefaultSmoothValue;
    }
    return (self);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.smooth = kDefaultSmoothValue;
    }
    return (self);
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.smooth = kDefaultSmoothValue;
    }
    return (self);
}


#pragma mark -
#pragma mark Drawing methods

- (void)drawValue:(CGFloat)v withOffset:(CGFloat)offset withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = CGPointMake(offset, (v * self.frame.size.height));
    
    if (point1.x > -1) {
        double x0 = (point0.x > -1) ? point0.x : point1.x;
        double y0 = (point0.y > -1) ? point0.y : point1.y;
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        
        float ctrl1_x = xm1 + (xc2 - xm1) * self.smooth + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * self.smooth + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * self.smooth + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * self.smooth + y2 - ym2;
        
        CGPathMoveToPoint(path, NULL, point1.x, point1.y);
        CGPathAddCurveToPoint(path, NULL, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
    }
}

- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect {
    if (!CGPathIsEmpty(path)) {
        NSInteger i = [self.dataSource numberOfValueInGraph:self] - 2;
        CGFloat value0 = [self.dataSource graph:self valueAtIndex:i];
        CGFloat value1 = [self.dataSource graph:self valueAtIndex:(i + 1)];
        if ((value0 != kUnvalidValue) && (value1 != kUnvalidValue)) {
            CGFloat offset0 = [self.dataSource graph:self offsetAtIndex:i];
            CGFloat offset1 = [self.dataSource graph:self offsetAtIndex:(i + 1)];
            CGFloat v = value1 + (value1 - value0);
            CGFloat o = offset1 + (offset1 - offset0);
            if ((CGPathIsEmpty(path))
                || (CGRectIntersectsRect(rect, CGRectMake(CGPathGetCurrentPoint(path).x, 0, o, self.frame.size.height)))) {
                [self drawValue:v
                     withOffset:o
                       withPath:path
                         inRect:rect];
            }
        }
    }
    [super drawPath:path withColor:color inRect:rect];
}

- (void)drawRect:(NSRect)rect {
    point0 = CGPointMake(-1, -1);
    point1 = CGPointMake(-1, -1);
    point2 = CGPointMake(-1, -1);
    point3 = CGPointMake(-1, -1);
    [super drawRect:rect];
}

@end
