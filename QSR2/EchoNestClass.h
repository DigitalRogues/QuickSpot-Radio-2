//
//  EchoNestClass.h
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Artist.h"
@protocol EchoNestDelegate <NSObject>
@optional
-(void)CatalogObjectsSynced;
-(void)ArtistObjectsSynced;
-(void)EchoSongListReady;

@end
@interface EchoNestClass : NSObject


@property (strong) id <EchoNestDelegate> echoDelegate;

-(void)syncCatalogObjects;
-(void)createStaticwithCatalog:(NSString *)catalogID andVariety:(NSNumber *)varietyValue;
-(void)syncArtistList:(NSString *)catIDLabel;
-(void)updateFavorites:(Artist *)favArtist andCatalog:(NSString *)catID;
-(void)syncCreate:(NSString *)catName;
-(void)syncAddArtist:(NSString *)artName catalofID:(NSString *)catID;
-(void)syncRemoveArtist:(NSString *)name itemid:(NSString *)itemid catalogID:(NSString *)catID;
- (void) syncRemove:(NSString *)catID;
@end
