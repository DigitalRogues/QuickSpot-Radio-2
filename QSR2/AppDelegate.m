//
//  AppDelegate.m
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData+MagicalRecord.h>
#import "Catalog.h"

@implementation AppDelegate

#pragma mark - General App methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//core data
	[MagicalRecord setupCoreDataStack];
	
	//UI
	[self menuBarSetUp];
	
	//Classes
	self.echoNestClass = [[EchoNestClass alloc] init];
	[self.echoNestClass setEchoDelegate:self];
	[self.echoNestClass syncCatalogObjects];
	
	self.spotifyClass = [[SpotifyClass alloc] init];
	[self.spotifyClass setSpotifyDelegate:self];
	[self.spotifyClass spotifyAutoLogin];
	
}

- (IBAction) quitApp:(id)sender
{
    // for testing login/logout credentials
    ///  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotifyUsers"];
	
    [MagicalRecord cleanUp];
	[[NSApplication sharedApplication] terminate:nil];
	
}

#pragma mark - Spotify Methods

- (IBAction) loginSubmit:(id)sender
{
    [self.spotifyClass loginWithUsername:[self.userField stringValue] andPassword:[self.passField stringValue]];
}


#pragma mark - Spotify Delegates

-(void)spotifyLoginSuccessful:(NSString *)loggedin
{
	if ([loggedin isEqualToString:@"NO"]) {
		[self.window makeKeyAndOrderFront:self];
	}
	
	else if ([loggedin isEqualToString:@"YES"])
		{
		NSLog(@"SPOTIFY LOGGED IN");
		}
		
	else
		{
		NSLog(@"LOGIN ERROR %@",loggedin);
		}
}




#pragma mark - EchoNest Delegate

-(void)CatalogObjectsSynced
{
	[self buildStationMenu];
}


#pragma mark - Menu UI actions

//	NSArray *catalogsSorted = [Catalog MR_findAllSortedBy:@"catalogName" ascending:YES inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
- (void) buildStationMenu
{
    if (self.stationsMenuItem) {
        [self.menu removeItem:self.stationsMenuItem];
    }
    self.stationsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Stations" action:nil keyEquivalent:@""];
    NSMenu * stationMenu = [[NSMenu alloc] init];
	
	NSArray *catalogsSorted = [Catalog MR_findAllSortedBy:@"catalogName" ascending:YES inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	
		for (Catalog *obj in catalogsSorted)
			{
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:obj.catalogName action:@selector(createStationWithCatalog:) keyEquivalent:@""];
            [stationMenu addItem:menuItem];
			}
		
        [self.stationsMenuItem setSubmenu:stationMenu];
        [self.menu insertItem:self.stationsMenuItem atIndex:0];
        [self.menu update];

}


-(void)menuBarSetUp
{
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.menu];
    [self.statusItem setTitle:@"QSR2"];
    [self.statusItem setHighlightMode:YES];
}

- (IBAction) showCatalogWindow:(id)sender
{
	self.catController = [[CatalogWindowController alloc]initWithWindowNibName:@"CatalogWindowController"];
    [self.catController showWindow:self];
}





@end
