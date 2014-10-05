//
//  Problem.h
//  BrowseMeetup
//
//  Created by Denis on 06.04.14.
//  Copyright (c) 2014 TAMIM Ziad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Problem : NSManagedObject

@property (nonatomic, retain) id categories;
@property (nonatomic, retain) NSString * description_;
@property (nonatomic, retain) NSNumber * edit_right;
@property (nonatomic, retain) id geometry;
@property (nonatomic, retain) NSString * id_;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * solution;
@property (nonatomic, retain) id supports;
@property (nonatomic, retain) NSString * time_closed;
@property (nonatomic, retain) NSString * time_created;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * town_id;

@end
