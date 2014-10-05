//
//  clMapViewController.h
//  MapBox
//
//  Created by Denis on 19.03.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@interface clAddProblemViewController : UIViewController
-(void)setLocation:(CLLocationCoordinate2D)location;
@end
@interface NSString (URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end