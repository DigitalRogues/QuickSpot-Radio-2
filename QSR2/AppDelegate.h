//
//  AppDelegate.h
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CatalogWindowController.h"
#import "EchoNestClass.h"
#import "SpotifyClass.h"
#import "Catalog.h"
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, EchoNestDelegate, SpotifyDelegate, GrowlApplicationBridgeDelegate>

@property (assign) IBOutlet NSWindow *window;
//spotify login window
@property (strong) IBOutlet NSTextField * userField;
@property (strong) IBOutlet NSTextField * passField;

//menu items
@property (strong)  NSStatusItem * statusItem;
@property (strong) NSMenuItem *stationsMenuItem;
@property (strong) IBOutlet NSMenu * menu;
@property (strong) IBOutlet NSMenuItem *pauseMenuItem;
//controllers
@property (strong) CatalogWindowController * catController;
@property (strong) EchoNestClass *echoNestClass;
@property (strong) SpotifyClass *spotifyClass;

//echonest objects
@property (strong) Catalog *replayCatObject;

//spotify objects
@property (strong) NSMutableArray *songArray;
- (IBAction) quitApp:(id)sender;
@end
