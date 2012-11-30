//
//  SWColor.m
//  StockWatcher
//
//  Created by Théo LUBERT on 9/12/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import "SWColor.h"

@implementation SWColor

+ (SWColor *)colorWithDeviceRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
#if TARGET_OS_IPHONE
    SWColor *c = [SWColor new];
    c.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return (c);
#else
    return ((SWColor *)[NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha]);
#endif
}

- (CGFloat)redComponent {
#if TARGET_OS_IPHONE
    const CGFloat *c = CGColorGetComponents(self.color.CGColor);
	return c[0];
#else
    return ([self redComponent]);
#endif
}

- (CGFloat)greenComponent {
#if TARGET_OS_IPHONE
    const CGFloat *c = CGColorGetComponents(self.color.CGColor);
	return c[1];
#else
    return ([self greenComponent]);
#endif
}

- (CGFloat)blueComponent {
#if TARGET_OS_IPHONE
    const CGFloat *c = CGColorGetComponents(self.color.CGColor);
	return c[2];
#else
    return ([self blueComponent]);
#endif
}

- (CGFloat)alphaComponent {
#if TARGET_OS_IPHONE
    const CGFloat *c = CGColorGetComponents(self.color.CGColor);
	return c[3];
#else
    return ([self alphaComponent]);
#endif
}

#if TARGET_OS_IPHONE
- (CGColorRef)CGColor {
    return ([self.color CGColor]);
}
#endif

@end
