//
//  SWTimeGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 11/14/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWGraph.h"

@class SWGraph;
@protocol SWTimeGraphDataSource <SWGraphDataSource>

- (CGFloat)graph:(SWGraph *)graph timeAtIndex:(NSString *)time;

@end

@interface SWTimeGraph : SWGraph

@end
