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
#import "Song.h"
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
	
    //init growl
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    
	//Classes
	self.echoNestClass = [[EchoNestClass alloc] init];
	[self.echoNestClass setEchoDelegate:self];
	[self.echoNestClass syncCatalogObjects];
	
	self.spotifyClass = [[SpotifyClass alloc] init];
	[self.spotifyClass setSpotifyDelegate:self];
	[self.spotifyClass spotifyAutoLogin];
	
    //artwork observer
    [self.spotifyClass addObserver:self forKeyPath:@"playbackManager.currentTrack.album.cover.image" options:NSKeyValueObservingOptionNew context:nil];
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

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
    if ([keyPath isEqualToString:@"playbackManager.currentTrack.album.cover.image"])
        {
        if (self.spotifyClass.playbackManager.currentTrack.album.cover.image != nil)
            {
            [self setGrowlPost:nil];
            }
        }
}


- (IBAction) quitApp:(id)sender
{
    // for testing login/logout credentials
    ///  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotifyUsers"];
	
    [MagicalRecord cleanUp];
	[[NSApplication sharedApplication] terminate:nil];
	
}

- (IBAction) setGrowlPost:(id)sender
{
    //uses growl registration dict plist file
    NSString * song = [NSString stringWithFormat:@"%@ by %@", self.spotifyClass.playbackManager.currentTrack.name, self.spotifyClass.playbackManager.currentTrack.consolidatedArtists];
    
    NSData * image = [self.spotifyClass.playbackManager.currentTrack.album.cover.image TIFFRepresentation];
    [GrowlApplicationBridge notifyWithTitle:@"Now Playing" description:song notificationName:@"New Song" iconData:image priority:0 isSticky:NO clickContext:nil];
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

#pragma mark - EchoNest Delegate

-(void)CatalogObjectsSynced
{
	[self buildStationMenu];
}

-(void)EchoSongListReady
{
    //fetch all song items from core data into array to send to next song.
    NSArray *songArray = [Song MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    self.songArray = [songArray mutableCopy];
    [self nextSong:nil];
}


#pragma mark - Spotify Methods

- (IBAction) loginSubmit:(id)sender
{
    [self.spotifyClass loginWithUsername:[self.userField stringValue] andPassword:[self.passField stringValue]];
}

-(IBAction)playPause:(id)sender
{
    
    switch (self.spotifyClass.playbackManager.isPlaying) {
        case 0:
            self.spotifyClass.playbackManager.isPlaying = TRUE;
            self.pauseMenuItem.title = @"Pause";
            [self.menu update];
            [self setGrowlPost:nil];
            break;
            
        case 1:
            self.spotifyClass.playbackManager.isPlaying = FALSE;
            self.pauseMenuItem.title = @"UnPause";
            [self.menu update];
        default:
            
            break;
    }
}


- (IBAction) nextSong:(id)sender
{
    
    if ([self.songArray count] > 0) {
        
        Song *songObject = [self.songArray objectAtIndex:0];
        [self.spotifyClass searchWithArtist:songObject.artistName andTitle:songObject.songTitle];
        [self.songArray removeObjectAtIndex:0];
    }
    else if ([self.songArray count] == 0)
        {
        
        [self sendCatalogIDandVariety];
        }
}


#pragma mark - Spotify Delegates

-(void)TrackDidEndPlayback
{
    [self nextSong:nil];
}

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
