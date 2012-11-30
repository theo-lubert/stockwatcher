//
//  SWScrollView.h
//  StockWatcher
//
//  Created by Théo LUBERT on 9/12/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#if TARGET_OS_IPHONE
#else
# import <Cocoa/Cocoa.h>
#endif

#if TARGET_OS_IPHONE
@protocol SWScrollViewDelegate <UIScrollViewDelegate>
#else
@protocol SWScrollViewDelegate
#endif
@end

#if TARGET_OS_IPHONE
@interface SWScrollView : UIScrollView
#else
@interface SWScrollView : NSScrollView
#endif

@end
