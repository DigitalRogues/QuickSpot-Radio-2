//
//  SpotifyClass.m
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import "SpotifyClass.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#include "appkey.c"

@implementation SpotifyClass

- (id) init
{
    self = [super init];
	
    if (self)
		{
        [self spotifyInit];
		}
	
    return self;
}

#pragma mark - Init methods

- (void) spotifyInit
{
    NSError * error = nil;
	
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey
                                                                        length:g_appkey_size]
                                               userAgent:@"com.bigb.QSR2"
                                           loadingPolicy:SPAsyncLoadingManual
                                                   error:&error];
	
    if (error != nil)
		{
        NSLog(@"CocoaLibSpotify init failed: %@", error);
        abort();
		}
	
    [[SPSession sharedSession] setDelegate:self];
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    self.playbackManager.delegate = self;
    [SPSession sharedSession].playbackDelegate = self;

    //add observer for search tracks
    [self addObserver:self forKeyPath:@"self.search.tracks" options:NSKeyValueObservingOptionNew context:nil];

}

#pragma mark - Playback method

-(IBAction)playTrack:(id)sender
{
    
    [SPAsyncLoading waitUntilLoaded:sender timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        
        SPTrack *loadedTrack = [loadedItems objectAtIndex:0];
        
        [self.playbackManager playTrack:loadedTrack callback:^(NSError *error) {
            
            if (error) {
                
                DDLogError(@"Broken Object: %@, %@",loadedTrack,loadedTrack.spotifyURL);
            }
        }];
        
    }];
}

#pragma mark - Spotify Login/Logout/Search

-(void)spotifyAutoLogin
{
	NSMutableDictionary * dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SpotifyUsers"] mutableCopy];
	
    if (dic != nil)
		{
        [[SPSession sharedSession] attemptLoginWithUserName:[[dic allKeys] lastObject] existingCredential:[[dic allValues] lastObject]];
		}
    ///show notification for no auto login
    else
		{
		//login unsuccessful pop up login window in app delegates delegate
		[self.spotifyDelegate spotifyLoginSuccessful:@"NO"];
		}
}

- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    if ([username length] > 0 &&
        [password length] > 0)
		{
        [[SPSession sharedSession] attemptLoginWithUserName:username
                                                   password:password];
		}
    else
		{
        NSBeep();
		}
}

-(void)searchWithArtist:(NSString *)artist andTitle:(NSString *)title
{
    
    
    NSString *searchString = [NSString stringWithFormat:@"spotify:search:artist:%@ title:%@",artist, title];
    searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
    NSURL *url = [NSURL URLWithString:searchString];
    self.search = [[SPSearch alloc] initWithURL:url inSession:[SPSession sharedSession]];
}


- (void)spotifyLogout
{
    [[SPSession sharedSession]logout:^{
        // code here
    }];
}

#pragma mark - Delegates


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"self.search.tracks"]) {
        if ([self.search.tracks count] > 0) {
            SPTrack *track = [self.search.tracks objectAtIndex:0];
            [self playTrack:track];
        }
        
    }
}


- (void) sessionDidEndPlayback:(id<SPSessionPlaybackProvider>)aSession
{
    [self.spotifyDelegate TrackDidEndPlayback];

}

-(void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager
{
    
}

- (void) sessionDidLoginSuccessfully:(SPSession *)aSession; {
	[self.spotifyDelegate spotifyLoginSuccessful:@"YES"];
	
}

- (void) session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
    // Invoked by SPSession after a failed login.
	NSString *errorString = [NSString stringWithFormat:@"%@",error];
    [self.spotifyDelegate spotifyLoginSuccessful:errorString];
}

- (void) session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * storedCredentials = [[defaults valueForKey:@"SpotifyUsers"] mutableCopy];
	
    if (storedCredentials == nil)
		{
        storedCredentials = [NSMutableDictionary dictionary];
		}
	
    [storedCredentials setValue:credential forKey:userName];
    [defaults setValue:storedCredentials forKey:@"SpotifyUsers"];
}

@end
