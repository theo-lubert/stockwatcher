//
//  SWAppDelegate.h
//  StockWatcher
//
//  Created by Théo LUBERT on 8/2/12.
//  Copyright (c) 2012 Théo LUBERT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SWShareGraph.h"

@interface SWAppDelegate : NSObject <NSApplicationDelegate, SWShareGraphDataSource> {
    SWShare *share;
}

@property (nonatomic, retain) IBOutlet NSMenu           *statusMenu;
@property (nonatomic, retain) NSStatusItem              *statusItem;

@property (nonatomic, retain) IBOutlet NSMenuItem       *item;
@property (nonatomic, retain) IBOutlet NSView           *contentView;

@property (nonatomic, retain) IBOutlet NSTabViewItem    *dayItem;
@property (nonatomic, retain) IBOutlet NSScrollView     *dayScroll;
@property (nonatomic, retain) IBOutlet SWShareGraph     *dayGraph;

@property (nonatomic, retain) IBOutlet NSTabViewItem    *weekItem;
@property (nonatomic, retain) IBOutlet NSScrollView     *weekScroll;
@property (nonatomic, retain) IBOutlet SWShareGraph     *weekGraph;

@property (nonatomic, retain) IBOutlet NSTabViewItem    *monthItem;
@property (nonatomic, retain) IBOutlet NSScrollView     *monthScroll;
@property (nonatomic, retain) IBOutlet SWShareGraph     *monthGraph;

@property (nonatomic, retain) IBOutlet NSTabViewItem    *yearItem;
@property (nonatomic, retain) IBOutlet NSScrollView     *yearScroll;
@property (nonatomic, retain) IBOutlet SWShareGraph     *yearGraph;

@property (nonatomic, retain) IBOutlet NSSearchField    *searchField;

- (IBAction)searchStock:(id)sender;

@end
