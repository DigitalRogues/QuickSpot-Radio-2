//
//  CatalogWindowController.m
//  Cipher
//
//  Created by punk on 7/15/12.
//  Copyright (c) 2012 Digital Rogues. All rights reserved.
//

#import "CatalogWindowController.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import <CoreData+MagicalRecord.h>
#import "Catalog.h"
#import "Artist.h"
@interface CatalogWindowController ()

@end
@implementation CatalogWindowController


- (void) windowWillLoad
{

    [NSApp activateIgnoringOtherApps:YES];
}

- (void) windowDidLoad
{



//    [self.addArtistButton setEnabled:NO];
    self.echoAPI = [[EchoNestClass alloc] init];
    [self.echoAPI setEchoDelegate:self];
    [self.echoAPI syncCatalogObjects];
//    self.listArray = [NSMutableArray array];
//    self.artistArray = [NSMutableArray array];
//    self.favArray = [NSMutableArray array];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullListArray:) name:@"listArrayReady" object:nil];
//    // init observers
//    [self addObservers];
//
//    // get list of catalogs form remote server
//    if (self.listArray.count == 0) {
//        [self.echoAPI syncCatalogs:nil];
//    }
//
//    [self.removeStationButton setEnabled:NO];
//    [self.varietySlider setEnabled:NO];
//    [self.removeArtistButton setEnabled:NO];
//
//    [self.addArtistButton setTarget:self];
//    [self.addArtistButton setAction:@selector(addArtistButton)];

}

- (void) addObservers
{
//    [self.echoAPI addObserver:self forKeyPath:@"artistArray" options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:@"self.artistArray" options:NSKeyValueObservingOptionNew context:nil];
//
}


- (void) dealloc
{
//    [self.echoAPI removeObserver:self forKeyPath:@"artistArray"];
//    [self removeObserver:self forKeyPath:@"self.artistArray"];
}


#pragma mark - Echo Delegates

- (void) ArtistObjectsSynced
{
    self.ArtistArray = [[Artist MR_findAllSortedBy:@"artistName" ascending:YES inContext:[NSManagedObjectContext MR_contextForCurrentThread]] mutableCopy];
    [self.artistTableView reloadData];
}

- (void) CatalogObjectsSynced
{
    [self buildCatalogPopUp:nil];
}

#pragma mark - api calls

// -(void)pullListArray:(NSNotification *)notification
// {
//
////    self.listArray = [[notification userInfo] objectForKey:@"array"];
////    [self buildCatalogPopUp:self.listArray];
//
//
// }
//
// - (IBAction) reloadCatalogs:(id)sender
// {
//	// [self.echoAPI syncCatalogs:nil];
// }
//
//
// -(void)syncArtistList
// {
//	  [self.echoAPI syncArtistList:self.currentCatalogObject.catalogID];
// }

- (void) parseFavoritesTag:(NSInteger)tag andState:(NSInteger)state
{

    Artist * artist = [self.artistArray objectAtIndex:tag];

    if (state == 1)
    {
        artist.isFavorite = @"true";
    }

    else if (state == 0)
    {
        artist.isFavorite = @"false";

    }

    ///send out  array to echo class and convert to json then sync
    [self.echoAPI updateFavorites:artist andCatalog:self.currentCatalogObject.catalogID];

}

#pragma mark - UI actions

- (IBAction) UpdateSettings:(id)sender
{

    [self.catalogDelegate CatalogwindowClosing];
    [self.window close];

}

- (void) controlTextDidChange:(NSNotification *)notification
{

    if ([notification object] == self.sheetField )
    {

        NSCharacterSet * set = [NSCharacterSet whitespaceCharacterSet];
        if (![[self.sheetField.stringValue stringByTrimmingCharactersInSet:set] length] == 0)
        {
            NSString * string = self.sheetField.stringValue;
            NSString * capitalized = [[[string substringToIndex:1] uppercaseString] stringByAppendingString:[string substringFromIndex:1]];
            // set text field with new capitalized word so pop up button can find it.
            self.sheetField.stringValue = capitalized;
            [self.addStationButton setEnabled:YES];
        }

        else
        {
            [self.addStationButton setEnabled:NO];
        }
    }


    if ([notification object] == self.artistNameField )
    {

        NSCharacterSet * set = [NSCharacterSet whitespaceCharacterSet];
        if (![[self.artistNameField.stringValue stringByTrimmingCharactersInSet:set] length] == 0)
        {
            [self.addArtistButton setEnabled:YES];
        }
        else
        {
            [self.addArtistButton setEnabled:NO];
        }

    }
}

#pragma mark - Station methods

- (IBAction) activateSheet:(id)sender
{

    if (!self.sheet)
    {
        [NSBundle loadNibNamed:@"SheetWindow" owner:self];
        [NSApp beginSheet:self.sheet
           modalForWindow:self.window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
        [self.addStationButton setEnabled:NO];
    }

}


- (IBAction) closeSheet:(id)sender
{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;


    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(selectNewCatalog)
                                   userInfo:nil
                                    repeats:NO];

}


- (IBAction) cancelSheet:(id)sender
{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;

}



- (void) selectNewCatalog
{
    if (self.sheetField.stringValue != nil)
    {
        [self.catalogPopUp selectItemWithTitle:self.sheetField.stringValue];
        [self popUpSelected:nil];
        [self.artistTableView reloadData];
    }

}


- (IBAction) addButton:(id)sender
{
    [self.echoAPI syncCreate:self.sheetField.stringValue];
    [self closeSheet:nil];
}


- (IBAction) removeButton:(id)sender
{

    if (!self.alertSheet)
    {
        [NSBundle loadNibNamed:@"AlertSheet" owner:self];
        [NSApp beginSheet:self.alertSheet
           modalForWindow:self.window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
}


- (IBAction) confirmStationDelete:(id)sender
{

    [self.echoAPI syncRemove:self.currentCatalogObject.catalogID];

    // remove from popup button
    [self.catalogPopUp selectItemAtIndex:0];
    [self.catalogPopUp removeItemWithTitle:self.currentCatalogObject.catalogName];
    [self closeAlertSheet:nil];


}

- (IBAction) closeAlertSheet:(id)sender
{
    [NSApp endSheet:self.alertSheet];
    [self.alertSheet close];
    self.alertSheet = nil;
}


#pragma mark - popup/sliders

- (void) buildCatalogPopUp:(id)sender
{
    // grab foirm CD
    NSArray * catalogArray = [Catalog MR_findAllSortedBy:@"catalogName"ascending:YES inContext:[NSManagedObjectContext MR_contextForCurrentThread]];

    for (Catalog * catObj in catalogArray)
    {
        [self.catalogPopUp addItemWithTitle:catObj.catalogName];
    }
}


- (IBAction) popUpSelected:(id)sender
{

    if ([sender indexOfSelectedItem] == 0)
    {
        self.popUpIndex = 0;
        [self.removeStationButton setEnabled:NO];
        [self.varietySlider setEnabled:NO];
        [self.removeArtistButton setEnabled:NO];
        [self.artistTableView reloadData];
    }

    if ([sender indexOfSelectedItem] > 0)
    {
        self.popUpIndex = [sender indexOfSelectedItem];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"catalogName == %@", [sender titleOfSelectedItem]];
        Catalog * catObj = [Catalog MR_findFirstWithPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];

        self.currentCatalogObject = catObj;
        [self.echoAPI syncArtistList:catObj.catalogID];

        // enable switches
        [self.removeStationButton setEnabled:YES];
        [self.varietySlider setEnabled:YES];
        [self.removeArtistButton setEnabled:YES];
    }


    // set variety slider
    NSString * keyName = [NSString stringWithFormat:@"varietyValue:%@", [self.catalogPopUp titleOfSelectedItem]];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:keyName])
    {
        self.varietySlider.doubleValue = 0.5;
        self.varietyValue.stringValue = [NSString stringWithFormat:@"5"];
    }
    else
    {

        self.varietySlider.doubleValue =  [[[NSUserDefaults standardUserDefaults] objectForKey:keyName] doubleValue];
        self.varietyValue.stringValue = [NSString stringWithFormat:@"%0.0f", self.varietySlider.doubleValue * 10];
    }

}


- (IBAction) sliderDidMove:(id)sender
{
    double value = [sender doubleValue];

    self.varietyValue.stringValue = [NSString stringWithFormat:@"%0.1f", value];
    NSEvent * event = [[NSApplication sharedApplication] currentEvent];
    BOOL startingDrag = event.type == NSLeftMouseDown;
    BOOL endingDrag = event.type == NSLeftMouseUp;
    BOOL dragging = event.type == NSLeftMouseDragged;

    NSAssert(startingDrag || endingDrag || dragging, @"unexpected event type caused slider change: %@", event);

    //    if (startingDrag) {
    //        NSLog(@"slider value started changing");
    //        // do whatever needs to be done when the slider starts changing
    //
    //
    //    }

    // do whatever needs to be done for "uncommitted" changes
    double dValue = [sender doubleValue] * 10;
    self.varietyValue.stringValue = [NSString stringWithFormat:@"%0.0f", dValue];
    // DDLogInfo(@"vaslue: %.2f",[sender doubleValue]);

    if (endingDrag)
    {
        NSLog(@"slider value stopped changing");
        // do whatever needs to be done when the slider stops changing
        NSString * keyName = [NSString stringWithFormat:@"varietyValue:%@", [self.catalogPopUp titleOfSelectedItem]];
        NSNumber * number = [NSNumber numberWithDouble:self.varietySlider.doubleValue];
        [[NSUserDefaults standardUserDefaults] setObject:number forKey:keyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



#pragma mark - artist functions

- (IBAction) addArtistButton:(id)sender
{

    NSCharacterSet * set = [NSCharacterSet whitespaceCharacterSet];

    // remove spaces from string
    if (![[self.artistNameField.stringValue stringByTrimmingCharactersInSet:set] length] == 0)
    {
        NSString * string = self.artistNameField.stringValue;
        [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [self.echoAPI syncAddArtist:string catalofID:self.currentCatalogObject.catalogID];
        self.artistNameField.stringValue = @"";


        // reload artist list

//        [NSTimer scheduledTimerWithTimeInterval:5
//                                         target:self
//                                       selector:@selector(syncArtistList)
//                                       userInfo:nil
//                                        repeats:NO];
    }

}



- (IBAction) removeArtistButton:(id)sender
{
    Artist * artistObj = [self.artistArray objectAtIndex:[self.artistTableView selectedRow]];

    [self.echoAPI syncRemoveArtist:artistObj.artistName itemid:artistObj.artistID catalogID:self.currentCatalogObject.catalogID];
}


- (IBAction) toggleFav:(id)sender
{

    [self parseFavoritesTag:[sender tag] andState:[sender state]];

}



#pragma mark - Array/TableView


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//        if ([keyPath isEqual:@"artistArray"])
//    {
//        // pull array for tableview
//    for (ArtistClass *item in self.echoAPI.artistArray) {
//
//    }
//        self.artistArray = self.echoAPI.artistArray;
//        [self.artistTableView reloadData];
//    }
//
//
//
//
//
//    if ([keyPath isEqualToString:@"self.artistArray"]) {
//    }
//


}




- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.artistTableView)
    {
        return [self.artistArray count];
    }

    return 0;
}


- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * identifier = [tableColumn identifier];

    if ([identifier isEqualToString:@"artistName"] && self.popUpIndex == 0)
    {
        // We pass us as the owner so we can setup target/actions into this main controller object
        NSTableCellView * cellView = [self.artistTableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = @"";
        return cellView;
    }




    else if ([identifier isEqualToString:@"artistName"])
    {
        // We pass us as the owner so we can setup target/actions into this main controller object
        NSTableCellView * cellView = [self.artistTableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        Artist * item = [self.artistArray objectAtIndex:row];
        if (!item.artistName)
        {
            item.artistName = @"placeholder - delete";
        }

        cellView.textField.stringValue = item.artistName;
        return cellView;

    }

    else if ([identifier isEqualToString:@"favorite"] && self.popUpIndex == 0)
    {
        return nil;
    }

    else if ([identifier isEqualToString:@"favorite"])
    {
        NSButton * button = [[NSButton alloc]init];
        [button setButtonType:NSSwitchButton];
        [button setTitle:@""];

        Artist * item = [self.artistArray objectAtIndex:row];

        [button setEnabled:YES];
        [button setState:NO];
        if ([item.isFavorite isEqualToString:@"true"])
        {
            [button setState:YES];
        }
        button.tag = row;
        [button setTarget:self];
        [button setAction:@selector(toggleFav:)];
        return button;
    }

    else
    {
        DDLogError(@"no view cell");
        return nil;
    }


}


- (void) tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.artistArray sortUsingDescriptors:[tableView sortDescriptors]];
    [tableView reloadData];
}

@end
