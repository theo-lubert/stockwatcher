//
//  SWDayGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/13/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWShareGraph.h"

@interface SWDayGraph : SWShareGraph {
    SWGraph             *lastCloseGraph;
}

@end
