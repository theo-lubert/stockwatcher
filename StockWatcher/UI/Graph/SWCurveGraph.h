//
//  SWCurveGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWGraph.h"

@interface SWCurveGraph : SWGraph

- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect;

@end
