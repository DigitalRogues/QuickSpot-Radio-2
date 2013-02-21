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
//    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
//    self.playbackManager.delegate = self;
//    [SPSession sharedSession].playbackDelegate = self;

}


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

#pragma mark - Delegates

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
