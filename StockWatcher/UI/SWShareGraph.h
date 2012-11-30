//
//  SWShareGraph.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/6/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#if TARGET_OS_IPHONE
#else
# import <Cocoa/Cocoa.h>
#endif
#import "SWScrollView.h"
#import "SWShare.h"
#import "SWGraph.h"
#import "SWCurveGraph.h"
#import "SWSmoothCurveGraph.h"
#import "SWVolumeGraph.h"
#import "SWPriceGraph.h"
#import "SWTimeGraph.h"

#define kVolumeGraphHeight  (0.2 * self.frame.size.height)

@protocol SWShareGraphDataSource <NSObject>

- (NSInteger)days;
- (NSDictionary *)dayDataAtIndex:(NSUInteger)index;

@end

@interface SWShareGraph : SWGraph <SWScrollViewDelegate, SWGraphDataSource, SWPriceGraphDataSource, SWTimeGraphDataSource> {
    SWScrollView        *scroll;
    NSMutableArray      *data;
    
    SWGraph             *timeGraph;
    SWGraph             *shareGraph;
    SWGraph             *shadowGraph;
    SWGraph             *mm20Graph;
    SWGraph             *mm50Graph;
    SWGraph             *volumeGraph;
    
    Boolean ready;
    
    float total;
    float step;
    
    float volMax;
    float max;
    float min;
}

@property (nonatomic, retain) IBOutlet id<SWShareGraphDataSource>   dataSource;
@property (nonatomic, retain) IBOutlet SWScrollView                 *parent;

- (SWGraph *)addGraph:(Class)class withColor:(SWColor *)color andFrame:(NSRect)rect;
- (void)updateWidth:(float)width ofView:(SWView *)v;
- (void)updateWidth:(float)width;

- (NSArray *)getData;
- (NSUInteger)numberOfValue;
- (void)drawVerticalLineAtX:(float)x withColor:(SWColor *)color inRect:(CGRect)rect;
- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect;
- (void)drawDay:(NSDictionary *)day atIndex:(int)i inRect:(CGRect)rect;

@end
