//
//  SWView.h
//  StockWatcher
//
//  Created by Théo LUBERT on 9/12/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#if TARGET_OS_IPHONE
#else
#import <Cocoa/Cocoa.h>
#endif


#if TARGET_OS_IPHONE
typedef CGRect      NSRect;
typedef CGSize      NSSize;
typedef CGPoint     NSPoint;

@interface SWView : UIView
#else
@interface SWView : NSView
#endif

- (CGContextRef)getGraphicContext;
- (void)setNeedsDisplay;

@end
