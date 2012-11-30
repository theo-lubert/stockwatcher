//
//  SWPriceGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 9/10/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWGraph.h"

typedef struct {
    CGFloat open;
    CGFloat lastClose;
    CGFloat close;
    CGFloat high;
    CGFloat low;
}   PriceData;

@class SWBarGraph;
@protocol SWPriceGraphDataSource <SWGraphDataSource>

- (PriceData)graph:(SWGraph *)graph priceDataAtIndex:(NSInteger)index;

@end

@interface SWPriceGraph : SWGraph

@property (nonatomic, retain) id<SWPriceGraphDataSource>    dataSource;

@end
