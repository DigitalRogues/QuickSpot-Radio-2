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


@end
