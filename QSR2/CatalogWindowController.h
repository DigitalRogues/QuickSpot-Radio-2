//
//  CatalogWindowController.h
//  Cipher
//
//  Created by punk on 7/15/12.
//  Copyright (c) 2012 Digital Rogues. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EchoNestClass.h"
#import "Catalog.h"
@protocol CatalogWindowDelegate <NSObject>
-(void)CatalogwindowClosing;


@end
@interface CatalogWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, EchoNestDelegate>


@property (strong) id <CatalogWindowDelegate> catalogDelegate;
@property (nonatomic, retain) EchoNestClass * echoAPI;
@property (nonatomic, retain) IBOutlet NSTableView * artistTableView;
@property (nonatomic, retain) NSMutableArray * artistArray;
@property (weak) IBOutlet NSTextField * artistNameField;
@property (weak) IBOutlet NSTextField * idLabel;
@property (strong) Catalog *currentCatalogObject;
@property (strong) IBOutlet NSPopUpButton *catalogPopUp;
@property (strong) IBOutlet NSWindow *sheet;
@property (strong) IBOutlet NSTextField *sheetField;
@property (strong) IBOutlet NSWindow *alertSheet;
@property (strong) IBOutlet NSButton *removeArtistButton;
@property (strong) IBOutlet NSButton *addArtistButton;
@property (strong) IBOutlet NSButton *addStationButton;
@property (strong) IBOutlet NSButton *removeStationButton;
@property  NSInteger popUpIndex;
@property (strong) IBOutlet NSSlider *varietySlider;
@property (strong) IBOutlet NSTextField *varietyValue;

@end
