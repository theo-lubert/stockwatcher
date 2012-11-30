//
//  SWGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/29/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#if TARGET_OS_IPHONE
#else
#import <Cocoa/Cocoa.h>
#endif
#import "SWView.h"
#import "SWColor.h"

#define kUnvalidValue   -1//CGFLOAT_MAX

@class SWGraph;
@protocol SWGraphDataSource <NSObject>

- (NSInteger)numberOfValueInGraph:(SWGraph *)graph;
- (CGFloat)graph:(SWGraph *)graph offsetAtIndex:(NSInteger)index;
- (CGFloat)graph:(SWGraph *)graph valueAtIndex:(NSInteger)index;
- (CGFloat)graph:(SWGraph *)graph widthAtIndex:(NSInteger)index;

@end

@interface SWGraph : SWView {
    CGContextRef    context;
}

@property (nonatomic, retain) id<SWGraphDataSource>   dataSource;
    
@property (nonatomic, retain) SWColor   *color;

@end
