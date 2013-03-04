//
//  EchoNestClass.m
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import "EchoNestClass.h"
#import <AFNetworking.h>
#import "Catalog.h"
#import "Artist.h"
#import "Song.h"

#define kAPIKEY  @"5LH6F9ILZRD5FL5C9"
#define kBASEURL @"http://developer.echonest.com/api/v4/playlist/"

@implementation EchoNestClass


-(void)syncCatalogObjects
{
	
	NSString * preURL      = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/catalog/list?api_key=%@&format=json", kAPIKEY];
	
    NSURL * url = [NSURL URLWithString:preURL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
	{
    [Catalog MR_truncateAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	for (id obj in [[JSON objectForKey:@"response"] objectForKey:@"catalogs"]) {
		Catalog *newCatalogObject = [Catalog MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
		newCatalogObject.catalogName = [obj objectForKey:@"name"];
		newCatalogObject.catalogID= [obj objectForKey:@"id"];
		
	}
			
	[self.echoDelegate CatalogObjectsSynced];
	
	}
										  
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
		{
		if (error) {
			NSLog(@"ERROR! %@",error);
		}
		
		}];
    [operation start];

	
	
}


- (void) createStaticwithCatalog:(NSString *)catalogID andVariety:(NSNumber *)varietyValue
{
    
    if (varietyValue == nil) {
        NSNumber *newNum = [NSNumber numberWithDouble:0.5];
        varietyValue = newNum;
    }
    
    NSInteger randString = (arc4random() % 2000000) + 1;
    NSString *string = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/playlist/static?api_key=%@&format=json&type=catalog-radio&seed_catalog=%@&variety=%.1f&bucket=id:spotify-WW&limit=true&results=50&_=%ld",kAPIKEY, catalogID,[varietyValue doubleValue],randString];
    NSURL * url = [NSURL URLWithString:string];
    
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON) {
        //clear out old songs
        [Song MR_truncateAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        for (id obj in [[JSON objectForKey:@"response"] objectForKey:@"songs"]) {
        Song *songObject = [Song MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            songObject.artistName = [obj objectForKey:@"artist_name"];
            songObject.songTitle = [obj objectForKey:@"title"];
        }
        
        [self.echoDelegate EchoSongListReady];
    }
                                          
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
    {
    DDLogError(@"JSON ERROR %@",error);
    }];
    
    [operation start];
}



- (void) syncArtistList:(NSString *)catIDLabel
{
    
    NSString * preURL      = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/catalog/read?api_key=%@&format=json&id=%@", kAPIKEY, catIDLabel];
    
    NSURL * url = [NSURL URLWithString:preURL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
    {
    [Artist MR_truncateAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    for (id obj in [[[JSON objectForKey:@"response" ] objectForKey:@"catalog"] objectForKey:@"items"]) {
        Artist *artistObj = [Artist MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        artistObj.artistName = [obj objectForKey:@"artist_name"];
        artistObj.artistID = [[obj objectForKey:@"request"] objectForKey:@"item_id"];
        
        if (![obj objectForKey:@"favorite"]) {
          artistObj.isFavorite = @"false";
        }
        
        else if ([obj objectForKey:@"favorite"])
            {
            artistObj.isFavorite = @"true";
            }
    }
    [self.echoDelegate ArtistObjectsSynced];
    }
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
                   DDLogError(@"Artist Error: %@",error);
        }];
    [operation start];
}

-(void)updateFavorites:(Artist *)favArtist andCatalog:(NSString *)catID
{
    Artist *artist = favArtist;
    NSInteger randString = (arc4random() % 2000000) + 1;
    NSString *string = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/catalog/favorite?api_key=%@&format=json&id=%@&item=%@&favorite=%@&_=%lu",kAPIKEY, catID,artist.artistID, artist.isFavorite,randString];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL * url = [NSURL URLWithString:string];
    DDLogInfo(@"Update Fav URL: %@",url);
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
    {
    DDLogInfo(@"JSonresponse %@",JSON);
    }
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
    {
    DDLogError(@"JSON ERROR %@ %@",error,JSON);
    }];
    
    [operation start];
    
}

- (void) syncCreate:(NSString *)catName
{
    NSURL * url = [NSURL URLWithString:@"http://developer.echonest.com"];
    
    AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"5LH6F9ILZRD5FL5C9", @"api_key",
                             @"json", @"format",
                             @"artist", @"type",
                             catName, @"name",
                             nil];
    NSURLRequest * request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                   path:@"/api/v4/catalog/create"
                                                             parameters:params
                                              constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
                                              }];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
    {                                                                       
    [self syncCatalogObjects];
    }
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
    {
                                                                                             
    }];
    
    
    [operation start];
}

- (void) syncAddArtist:(NSString *)artName catalofID:(NSString *)catID
{
    NSString * jsonString = [NSString stringWithFormat:@"[{\"item\":{\"item_id\":\"%@\",\"artist_name\":\"%@\"}}]", artName, artName];
    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:@"http://developer.echonest.com"];
    AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"5LH6F9ILZRD5FL5C9", @"api_key",
                             @"json", @"format",
                             @"json", @"data_type",
                             @"artist", @"type",
                             catID, @"id",
                             data, @"data",
                             nil];
    NSURLRequest * request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                   path:@"/api/v4/catalog/update"
                                                             parameters:params
                                              constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
                                              }];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
    {
       [self syncArtistList:catID];
    }
                                          
   failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
    {
                                                                                             
    }];
    
    
    [operation start];
}

- (void) syncRemoveArtist:(NSString *)name itemid:(NSString *)itemid catalogID:(NSString *)catID
{
    NSString * jsonString = [NSString stringWithFormat:@"[{\"action\":\"delete\",\"item\":{\"item_id\":\"%@\",\"artist_name\":\"%@\"}}]", itemid, name];
    
    
    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:@"http://developer.echonest.com"];
    AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"5LH6F9ILZRD5FL5C9", @"api_key",
                             @"json", @"format",
                             @"json", @"data_type",
                             @"artist", @"type",
                             catID, @"id",
                             data, @"data",
                             nil];
    NSURLRequest * request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                   path:@"/api/v4/catalog/update"
                                                             parameters:params
                                              constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
                                              }];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
                                          {
                                              DDLogInfo(@"JSON: %@",JSON);
                                          [self syncArtistList:catID];
                                          }
                                          
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON) {
                                                                                             
                                                                                         }];
    
    [operation start];
}



- (void) syncRemove:(NSString *)catID
{
    NSURL * url = [NSURL URLWithString:@"http://developer.echonest.com"];
    
    AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"5LH6F9ILZRD5FL5C9", @"api_key",
                             @"json", @"format",
                             catID, @"id",
                             nil];
    NSURLRequest * request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                   path:@"/api/v4/catalog/delete"
                                                             parameters:params
                                              constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
                                              }];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
    {
    [self syncCatalogObjects];
    }
    failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON) {
                                                                                             
                                                                                         }];
    
    
    [operation start];
}


@end
