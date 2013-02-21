//
//  Catalog.h
//  QSR2
//
//  Created by punk on 2/21/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Catalog : NSManagedObject

@property (nonatomic, retain) NSString * catalogName;
@property (nonatomic, retain) NSString * catalogID;
@property (nonatomic, retain) NSNumber * sliderValue;

@end
