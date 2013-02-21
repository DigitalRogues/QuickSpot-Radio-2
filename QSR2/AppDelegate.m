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
#import "LumberjackFormatter.h"


@implementation AppDelegate

#pragma mark - General App methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//core data
	[MagicalRecord setupCoreDataStack];
	
    //setup logging
    [self setupLumberjack];
    
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


-(void)setupLumberjack
{
	//activate lumberjack logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //set up custom logging options
    
    LumberjackFormatter *formatter = [[LumberjackFormatter alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    NSColor *pink = [NSColor colorWithCalibratedRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
    NSColor *purple = [NSColor colorWithCalibratedRed:0.376 green:0.193 blue:0.579 alpha:1.000];
    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:purple backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    

}

- (IBAction) quitApp:(id)sender
{
    // for testing login/logout credentials
    ///  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotifyUsers"];
	
    [MagicalRecord cleanUp];
	[[NSApplication sharedApplication] terminate:nil];
	
}

#pragma mark - EchoNest Methods

- (void) createStationWithCatalog:(id)sender
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogName == %@", [sender title]];
    
    Catalog *catalogObject = [Catalog MR_findFirstWithPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //save catalogID for replay
    self.replayCatObject = catalogObject;
    
    //takes self.catreplayobject and sends to create statis catalog in EN class
    [self sendCatalogIDandVariety];
    
    
    
}

-(void)sendCatalogIDandVariety
{
    NSString *keyName = [NSString stringWithFormat:@"varietyValue:%@",self.replayCatObject.catalogName];
    NSNumber *varietyValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyName];
    [self.echoNestClass createStaticwithCatalog:self.replayCatObject.catalogID andVariety:varietyValue];
    
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
		DDLogInfo(@"SPOTIFY LOGGED IN");
		}
		
	else
		{
		DDLogError(@"LOGIN ERROR %@",loggedin);
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
