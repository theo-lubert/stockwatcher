//
//  SWSmoothCurveGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWCurveGraph.h"

#define kDefaultSmoothValue 0.8

@interface SWSmoothCurveGraph : SWCurveGraph {
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
}

@property (nonatomic, assign) CGFloat   smooth;

@end
