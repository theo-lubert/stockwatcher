//
//  SWView.m
//  StockWatcher
//
//  Created by Théo LUBERT on 9/12/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWView.h"

@implementation SWView

- (CGContextRef)getGraphicContext {
#if TARGET_OS_IPHONE
    return (UIGraphicsGetCurrentContext());
#else
    return ((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort]);
#endif
}

- (void)setNeedsDisplay {
#if TARGET_OS_IPHONE
    [super setNeedsDisplay];
#else
    [super setNeedsDisplay:YES];
#endif
}

@end
