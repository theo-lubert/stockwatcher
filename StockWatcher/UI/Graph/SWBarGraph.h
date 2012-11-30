//
//  SWBarGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 9/4/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#if TARGET_OS_IPHONE
#else
# import <Cocoa/Cocoa.h>
#endif
#import "SWPriceGraph.h"

#define kBarMaxWidth    15.0

@interface SWBarGraph : SWPriceGraph

@end
