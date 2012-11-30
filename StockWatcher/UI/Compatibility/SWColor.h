//
//  SWColor.h
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
@interface SWColor : UIColor

@property (nonatomic, retain) UIColor   *color;

#else
@interface SWColor : NSColor
#endif

+ (SWColor *)colorWithDeviceRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (CGFloat)redComponent;
- (CGFloat)greenComponent;
- (CGFloat)blueComponent;
- (CGFloat)alphaComponent;

//- (CGColorRef)CGColor;

@end
