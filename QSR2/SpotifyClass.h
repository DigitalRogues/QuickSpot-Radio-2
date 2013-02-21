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

@end


@interface SpotifyClass : NSObject <SPSessionDelegate>

@property (strong) id <SpotifyDelegate> spotifyDelegate;

-(void)spotifyAutoLogin;
- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password;
@end
