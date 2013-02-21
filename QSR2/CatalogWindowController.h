//
//  CatalogWindowController.h
//  Cipher
//
//  Created by punk on 7/15/12.
//  Copyright (c) 2012 Digital Rogues. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EchoNestClass.h"


@interface CatalogWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>



@property (nonatomic, retain) EchoNestClass * echoAPI;
@property (nonatomic, retain) IBOutlet NSTableView * artistTableView;
@property (strong) NSMutableArray * listArray;
@property (nonatomic, retain) NSMutableArray * artistArray;
@property (weak) IBOutlet NSTextField * artistNameField;
@property (weak) IBOutlet NSTextField * idLabel;
@property (strong) NSMutableArray *favArray;
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


-(IBAction)sliderDidMove:(id)sender;
-(IBAction)cancelSheet:(id)sender;
-(IBAction)closeAlertSheet:(id)sender;
-(IBAction)confirmStationDelete:(id)sender;
- (IBAction)activateSheet:(id)sender;
- (IBAction)closeSheet:(id)sender;
- (IBAction)popUpSelected:(id)sender;
- (IBAction) removeArtistButton:(id) sender;
- (IBAction) addArtistButton:(id) sender;
- (IBAction) addButton:(id) sender;
- (IBAction) removeButton:(id) sender;
- (IBAction) reloadCatalogs:(id) sender;
- (IBAction)toggleFav:(id)sender;
@end
