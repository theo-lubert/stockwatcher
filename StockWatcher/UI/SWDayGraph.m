//
//  SWDayGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/13/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWDayGraph.h"
#import "SWLastPriceGraph.h"

@implementation SWDayGraph

- (NSUInteger)numberOfValueOnScreen {
    return (1);
}

- (NSUInteger)numberOfValue {
    return (3);
}

- (void)drawIntraDay:(NSDictionary *)day withStep:(float)s andOffset:(float)offset withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    float o = [[day objectForKey:@"open"] floatValue];
    float c = [[day objectForKey:@"close"] floatValue];
    if (c != -1) {
        o = (o - min) / (max - min);
        c = (c - min) / (max - min);
        
        if (!CGPathIsEmpty(path)) {
            CGPathAddLineToPoint(path, NULL, (offset + s), (kVolumeGraphHeight + (c * (self.frame.size.height - kVolumeGraphHeight))));
        } else {
            CGPathMoveToPoint(path, NULL, offset, (kVolumeGraphHeight + (o * (self.frame.size.height - kVolumeGraphHeight))));
            CGPathAddLineToPoint(path, NULL, (offset + s), (kVolumeGraphHeight + (c * (self.frame.size.height - kVolumeGraphHeight))));
        }
    }
}

- (void)drawDay:(NSDictionary *)day atIndex:(int)i inRect:(CGRect)rect {
    [self drawVerticalLineAtX:(i * step) withColor:[SWColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.05] inRect:rect];
}

- (DayIndex)indexOfDayFromIndex:(NSInteger)index {
    NSInteger i = 0;
    NSInteger count = 0;
    for (NSInteger k=MIN(index, [super numberOfValueInGraph:volumeGraph]); i<k; i++) {
        NSArray *intraday = [[[self getData] objectAtIndex:i] objectForKey:@"intraday"];
        if (intraday) {
            if (index < (count + intraday.count)) {
                return ((DayIndex) {
                    .day = i,
                    .intra = (index - count)
                });
            }
            count += intraday.count;
        } else {
            count++;
        }
    }
    return ((DayIndex) {
        .day = i,
        .intra = 0
    });
}

- (DayIndex)indexOfDayFromIndex:(NSInteger)index withIntraday:(Boolean)intra {
    if (intra) {
        return ([self indexOfDayFromIndex:index]);
    }
    return ((DayIndex) {
        .day = index,
        .intra = 0
    });
}

- (NSRect)lastCloseGraphFrame {
    return ((NSRect) {
        .origin.x = 0,
        .origin.y = kVolumeGraphHeight,
        .size.width = self.frame.size.width,
        .size.height = self.frame.size.height - kVolumeGraphHeight
    });
}

- (void)addLastCloseGraph {
    lastCloseGraph = [self addGraph:[SWLastPriceGraph class]
                          withColor:[SWColor colorWithDeviceRed:1.0 green:0.1 blue:0.1 alpha:0.15]
                           andFrame:[self lastCloseGraphFrame]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addLastCloseGraph];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    
    [lastCloseGraph setNeedsDisplay];
}

- (void)updateWidth:(float)width {
    [self updateWidth:(total * step) ofView:lastCloseGraph];
    
    [super updateWidth:width];
}


#pragma mark -
#pragma mark Graphs dataSource methods

- (NSInteger)numberOfValueInGraph:(SWGraph *)graph {
    NSInteger count = 0;
    for (NSInteger i=0, k=[super numberOfValueInGraph:nil]; i<k; i++) {
        NSDictionary *day = [[self getData] objectAtIndex:i];
        NSArray *intraday = [day objectForKey:@"intraday"];
        if ((intraday) && (graph != lastCloseGraph)) {
            count += intraday.count;
        } else {
            count++;
        }
    }
    return (count);
}

- (CGFloat)graph:(SWGraph *)graph offsetAtIndex:(NSInteger)index {
    DayIndex dayIndex = [self indexOfDayFromIndex:index withIntraday:(graph != lastCloseGraph)];
    NSDictionary *day = [[self getData] objectAtIndex:dayIndex.day];
    
    NSArray *intraday = [day objectForKey:@"intraday"];
    if ((intraday) && (graph != lastCloseGraph)) {
        float openTS = [[day objectForKey:@"openTimestamp"] floatValue];
        float closeTS = [[day objectForKey:@"closeTimestamp"] floatValue];
        float lastTS = openTS;
        
        NSDictionary *d = nil;
        if (dayIndex.intra > 0) {
            d = [intraday objectAtIndex:(dayIndex.intra - 1)];
            lastTS = [[d objectForKey:@"timestamp"] floatValue];
        }
        d = [intraday objectAtIndex:dayIndex.intra];
        float offset = (dayIndex.day * step) + ((lastTS - openTS) / (closeTS - openTS)) * step;
        
        return (offset);
    }
    return (dayIndex.day * step);
}

- (CGFloat)graph:(SWGraph *)graph valueAtIndex:(NSInteger)index {
    if ([graph isKindOfClass:[SWCurveGraph class]]) {
        DayIndex dayIndex = [self indexOfDayFromIndex:index withIntraday:(graph != lastCloseGraph)];
        NSDictionary *day = [[self getData] objectAtIndex:dayIndex.day];
        NSArray *intraday = [day objectForKey:@"intraday"];
        if (intraday) {
            NSDictionary *d = [intraday objectAtIndex:dayIndex.intra];
            if ((graph == shareGraph) || (graph == shadowGraph)) {
                return (([[d objectForKey:@"close"] floatValue] - min) / (max - min));
            } else if (graph == mm20Graph) {
                if ([d objectForKey:@"mm20"] == nil) {
                    return (kUnvalidValue);
                }
                return (([[d objectForKey:@"mm20"] floatValue] - min) / (max - min));
            } else if (graph == mm50Graph) {
                if ([d objectForKey:@"mm50"] == nil) {
                    return (kUnvalidValue);
                }
                return (([[d objectForKey:@"mm50"] floatValue] - min) / (max - min));
            } else {
                return (kUnvalidValue);
            }
        } else {
            return (kUnvalidValue);
        }
    }
    DayIndex dayIndex = [self indexOfDayFromIndex:index withIntraday:(graph != lastCloseGraph)];
    NSDictionary *day = [[self getData] objectAtIndex:dayIndex.day];
    
    NSArray *intraday = [day objectForKey:@"intraday"];
    if ((intraday) && (graph != lastCloseGraph)) {
        float vMax = [[day objectForKey:@"intradayMaxVolume"] floatValue];
        float o = [[day objectForKey:@"open"] floatValue];
        o = (o - min) / (max - min);
        
        NSDictionary *d = [intraday objectAtIndex:dayIndex.intra];
        return ([[d objectForKey:@"volume"] floatValue] / vMax);
    }
    return ([[day objectForKey:@"volume"] floatValue] / volMax);
}

- (CGFloat)graph:(SWGraph *)graph widthAtIndex:(NSInteger)index {
    DayIndex dayIndex = [self indexOfDayFromIndex:index withIntraday:(graph != lastCloseGraph)];
    NSDictionary *day = [[self getData] objectAtIndex:dayIndex.day];
    
    NSArray *intraday = [day objectForKey:@"intraday"];
    if ((intraday) && (graph != lastCloseGraph)) {
        float openTS = [[day objectForKey:@"openTimestamp"] floatValue];
        float closeTS = [[day objectForKey:@"closeTimestamp"] floatValue];
        float lastTS = openTS;
        
        NSDictionary *d = nil;
        if (dayIndex.intra > 0) {
            d = [intraday objectAtIndex:(dayIndex.intra - 1)];
            lastTS = [[d objectForKey:@"timestamp"] floatValue];
        }
        d = [intraday objectAtIndex:dayIndex.intra];
        float timestamp = [[d objectForKey:@"timestamp"] floatValue];
        float s = ((timestamp - lastTS) / (closeTS - openTS)) * step;
        
        return (s);
    }
    return (step);
}


#pragma mark -
#pragma mark Graphs dataSource methods

- (PriceData)graph:(SWGraph *)graph priceDataAtIndex:(NSInteger)index {
    DayIndex dayIndex = [self indexOfDayFromIndex:index withIntraday:(graph != lastCloseGraph)];
    NSDictionary *day = [[self getData] objectAtIndex:dayIndex.day];
    
    NSArray *intraday = [day objectForKey:@"intraday"];
    if ((intraday) && (graph != lastCloseGraph)) {
        NSDictionary *d = [intraday objectAtIndex:dayIndex.intra];
        return (PriceData) {
            .open = (([[d objectForKey:@"open"] floatValue] - min) / (max - min)),
            .lastClose = (([[d objectForKey:@"lastClose"] floatValue] - min) / (max - min)),
            .close = (([[d objectForKey:@"close"] floatValue] - min) / (max - min)),
            .high = (([[d objectForKey:@"high"] floatValue] - min) / (max - min)),
            .low = (([[d objectForKey:@"low"] floatValue] - min) / (max - min))
        };
    }
    return (PriceData) {
        .open = (([[day objectForKey:@"open"] floatValue] - min) / (max - min)),
        .lastClose = (([[day objectForKey:@"lastClose"] floatValue] - min) / (max - min)),
        .close = (([[day objectForKey:@"close"] floatValue] - min) / (max - min)),
        .high = (([[day objectForKey:@"high"] floatValue] - min) / (max - min)),
        .low = (([[day objectForKey:@"low"] floatValue] - min) / (max - min))
    };
}

@end
