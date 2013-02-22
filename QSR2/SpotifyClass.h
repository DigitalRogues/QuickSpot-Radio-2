//
//  SpotifyClass.h
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
@protocol SpotifyDelegate <NSObject>
@required
-(void)spotifyLoginSuccessful:(NSString *)loggedin;
-(void)TrackDidEndPlayback;
@end


@interface SpotifyClass : NSObject <SPSessionDelegate, SPPlaybackManagerDelegate, SPSessionPlaybackDelegate>

@property (strong) id <SpotifyDelegate> spotifyDelegate;
@property (strong) SPSearch *search;
@property (strong) SPPlaybackManager *playbackManager;


-(void)spotifyAutoLogin;
- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password;
-(void)searchWithArtist:(NSString *)artist andTitle:(NSString *)title;
@end
