//
//  SWShareGraph.m
//  StockWatcher
//
//  Created by Théo LUBERT on 8/6/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWShareGraph.h"
#import "SWAppDelegate.h"
#import "SWBarGraph.h"

@implementation SWShareGraph

- (NSUInteger)numberOfValueOnScreen {
    return (100);
}

- (NSUInteger)numberOfValue {
    return (100);
}

- (NSRect)shadowFrame {
    return ((NSRect) {
        .origin.x = 0,
        .origin.y = kVolumeGraphHeight - 1,
        .size.width = self.frame.size.width,
        .size.height = self.frame.size.height - kVolumeGraphHeight
    });
}

- (NSRect)shareGraphFrame {
    return ((NSRect) {
        .origin.x = 0,
        .origin.y = kVolumeGraphHeight,
        .size.width = self.frame.size.width,
        .size.height = self.frame.size.height - kVolumeGraphHeight
    });
}

- (NSRect)mm20GraphFrame {
    return ((NSRect) {
        .origin.x = 0,
        .origin.y = kVolumeGraphHeight,
        .size.width = self.frame.size.width,
        .size.height = self.frame.size.height - kVolumeGraphHeight
    });
}

- (NSRect)mm50GraphFrame {
    return ((NSRect) {
        .origin.x = 0,
        .origin.y = kVolumeGraphHeight,
        .size.width = self.frame.size.width,
        .size.height = self.frame.size.height - kVolumeGraphHeight
    });
}

- (NSRect)volumeGraphFrame {
    return ((NSRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = self.frame.size.width,
        .size.height = kVolumeGraphHeight
    });
}

- (SWGraph *)addGraph:(Class)class withColor:(SWColor *)color andFrame:(NSRect)rect {
    SWGraph *g = [[class alloc] initWithFrame:rect];
    [g setColor:color];
    [self addSubview:g];
    [g setDataSource:self];
    return (g);
}

- (void)addShadowGraph {
    shadowGraph = [self addGraph:[SWCurveGraph class]
                       withColor:[SWColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5]
                        andFrame:[self shadowFrame]];
}

- (void)addShareGraph {
    shareGraph = [self addGraph:[SWBarGraph class]
                      withColor:[SWColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5]
                       andFrame:[self shareGraphFrame]];
}

- (void)addMM20Graph {
    mm20Graph = [self addGraph:[SWSmoothCurveGraph class]
                     withColor:[SWColor colorWithDeviceRed:1.0 green:0.1 blue:0.1 alpha:0.3]
                      andFrame:[self shareGraphFrame]];
}

- (void)addMM50Graph {
    mm50Graph = [self addGraph:[SWSmoothCurveGraph class]
                     withColor:[SWColor colorWithDeviceRed:0.1 green:0.1 blue:1.0 alpha:0.3]
                      andFrame:[self shareGraphFrame]];
}

- (void)addVolumeGraph {
    volumeGraph = [self addGraph:[SWVolumeGraph class]
                       withColor:[SWColor colorWithDeviceRed:0.15 green:0.7 blue:1 alpha:1]
                        andFrame:[self volumeGraphFrame]];
}

- (void)awakeFromNib {
    ready = NO;
    [self setColor:[SWColor colorWithDeviceRed:0.15 green:0.7 blue:1 alpha:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSize) name:kSWShareFinacialDataUpdated object:nil];
    
    [self addVolumeGraph];
//    [self addShadowGraph];
    [self addShareGraph];
    [self addMM20Graph];
    [self addMM50Graph];
}

- (void)scrollToRight {
    NSPoint p = (NSPoint) {
        .x = self.frame.size.width - _parent.frame.size.width,
        .y = 0,
    };
#if TARGET_OS_IPHONE
    [_parent setContentOffset:p animated:NO];
#else
    [[_parent contentView] scrollToPoint:p];
#endif
    ready = (p.x > 0);
}

- (void)updateWidth:(float)width ofView:(SWView *)v {
    [v setFrame:(NSRect) {
        .origin = v.frame.origin,
        .size.width = width,
        .size.height = v.frame.size.height
    }];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    
    [volumeGraph setNeedsDisplay];
    [shareGraph setNeedsDisplay];
    [shadowGraph setNeedsDisplay];
    [mm20Graph setNeedsDisplay];
    [mm50Graph setNeedsDisplay];
}

- (void)updateWidth:(float)width {
    [self updateWidth:(total * step) ofView:self];
    [self updateWidth:(total * step) ofView:volumeGraph];
    [self updateWidth:(total * step) ofView:shareGraph];
    [self updateWidth:(total * step) ofView:shadowGraph];
    [self updateWidth:(total * step) ofView:mm20Graph];
    [self updateWidth:(total * step) ofView:mm50Graph];
    
    [self setNeedsDisplay];
}

- (void)updateSize {
    data = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(days)]) {
        total = MIN([self.dataSource days], [self numberOfValue]);
    } else {
        total = [self numberOfValueOnScreen];
    }
    step = _parent.frame.size.width / [self numberOfValueOnScreen];
#if TARGET_OS_IPHONE
    [_parent setContentSize:(NSSize) {
        .width = (total * step),
        .height = self.frame.size.height
    }];
#endif
    
//    data = nil;
    [self updateWidth:(total * step)];
    if (!ready) {
        [self scrollToRight];
    }
}

- (void)drawVerticalLineAtX:(float)x withColor:(SWColor *)color inRect:(CGRect)rect {
    if (CGRectIntersectsRect(rect, CGRectMake(x, 0, 1, self.frame.size.height))) {
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);
        CGContextMoveToPoint(context, x, kVolumeGraphHeight);
        CGContextAddLineToPoint(context, x, self.frame.size.height);
        CGContextStrokePath(context);
        CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], ([color alphaComponent] / 2.0));
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, kVolumeGraphHeight);
        CGContextStrokePath(context);
    }
}

- (void)drawPath:(CGMutablePathRef)path withColor:(SWColor *)color inRect:(CGRect)rect {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, -0.5);
    CGContextSetLineWidth(context, 2);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.5);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
}

- (NSArray *)getData {
    if (data == nil) {
        volMax = -1;
        max = -1;
        min = -1;
        
        data = [NSMutableArray new];
        
        for (int i=(total-1); i>=0; i--) {
            NSDictionary *day = nil;
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(dayDataAtIndex:)]) {
                day = [self.dataSource dayDataAtIndex:i];
            }
            
            if (day != nil) {
                float tmp = [[day objectForKey:@"high"] floatValue];
                max = (max == -1) ? tmp : MAX(max, tmp);
                tmp = [[day objectForKey:@"low"] floatValue];
                min = (min == -1) ? tmp : MIN(min, tmp);
                
//                if ([day objectForKey:@"mm20"]) {
//                    tmp = [[day objectForKey:@"mm20"] floatValue];
//                    max = MAX(max, tmp);
//                    min = MIN(min, tmp);
//                }
//                if ([day objectForKey:@"mm50"]) {
//                    tmp = [[day objectForKey:@"mm50"] floatValue];
//                    max = MAX(max, tmp);
//                    min = MIN(min, tmp);
//                }
                
                tmp = [[day objectForKey:@"volume"] floatValue];
                volMax = (volMax == -1) ? tmp : MAX(volMax, tmp);
                [data addObject:day];
            }
        }
        max += (max - min) * 0.02;
        min = MAX(0, (min - ((max - min) * 0.02)));
    }
    return (data);
}

- (void)drawDay:(NSDictionary *)day atIndex:(int)i withPath:(CGMutablePathRef)path inRect:(CGRect)rect {
    // do nothing
}

- (void)drawRect:(NSRect)rect {
    context = [self getGraphicContext];
#if TARGET_OS_IPHONE
    self.transform = CGAffineTransformMakeScale(1.0, -1.0);
#endif
    
    NSArray *d = [self getData];
    for (int i=0; i<total; i++) {
        [self drawDay:[d objectAtIndex:i] atIndex:i inRect:rect];
    }
}

- (void)layoutSubviews {
#if TARGET_OS_IPHONE
    [super layoutSubviews];
#endif
    
    [shareGraph setFrame:[self shareGraphFrame]];
    [shadowGraph setFrame:[self shadowFrame]];
    [mm20Graph setFrame:[self mm20GraphFrame]];
    [mm50Graph setFrame:[self mm50GraphFrame]];
    [volumeGraph setFrame:[self volumeGraphFrame]];
    
    [self updateWidth:(total * step) ofView:volumeGraph];
    [self updateWidth:(total * step) ofView:shareGraph];
    [self updateWidth:(total * step) ofView:shadowGraph];
    [self updateWidth:(total * step) ofView:mm20Graph];
    [self updateWidth:(total * step) ofView:mm50Graph];
}


#pragma mark -
#pragma mark Graphs dataSource methods

- (NSInteger)numberOfValueInGraph:(SWGraph *)graph {
    return ((NSInteger)total);
}

- (CGFloat)graph:(SWGraph *)graph offsetAtIndex:(NSInteger)index {
    if ([graph isKindOfClass:[SWCurveGraph class]]) {
        return ((index + 1) * step);
    }
    return (index * step);
}

- (CGFloat)graph:(SWGraph *)graph valueAtIndex:(NSInteger)index {
    if ([graph isKindOfClass:[SWCurveGraph class]]) {
        NSDictionary *d = [[self getData] objectAtIndex:index];
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
    }
    return ([[[[self getData] objectAtIndex:index] objectForKey:@"volume"] floatValue] / volMax);
}

- (CGFloat)graph:(SWGraph *)graph widthAtIndex:(NSInteger)index {
    return (step);
}


#pragma mark -
#pragma mark Graphs dataSource methods

- (PriceData)graph:(SWGraph *)graph priceDataAtIndex:(NSInteger)index {
    NSDictionary *d = [[self getData] objectAtIndex:index];
    return (PriceData) {
        .open = (([[d objectForKey:@"open"] floatValue] - min) / (max - min)),
        .lastClose = (([[d objectForKey:@"lastClose"] floatValue] - min) / (max - min)),
        .close = (([[d objectForKey:@"close"] floatValue] - min) / (max - min)),
        .high = (([[d objectForKey:@"high"] floatValue] - min) / (max - min)),
        .low = (([[d objectForKey:@"low"] floatValue] - min) / (max - min))
    };
}

@end
