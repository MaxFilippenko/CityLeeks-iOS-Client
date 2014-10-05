//
//  Category.h
//  CityLeeks
//
//  Created by Denis on 12.04.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * id_;
@property (nonatomic, retain) NSString * name;

@end
