//
//  Notification.h
//  BrowseMeetup
//
//  Created by Denis on 07.04.14.
//  Copyright (c) 2014 TAMIM Ziad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) id categories;
@property (nonatomic, retain) NSString * description_;
@property (nonatomic, retain) id geometry;
@property (nonatomic, retain) NSString * id_;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) id support;

@end
