//
//  EchoNestClass.h
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol EchoNestDelegate <NSObject>
@optional
-(void)CatalogObjectsSynced;

@end
@interface EchoNestClass : NSObject


@property (strong) id <EchoNestDelegate> echoDelegate;

-(void)syncCatalogObjects;
@end
