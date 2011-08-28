//
//  RouteModel.h
//  CycleStreets
//
//  Created by neil on 22/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import "MBProgressHUD.h"
#import "Route.h"
#import "Query.h"

@interface RouteManager : FrameworkObject <MBProgressHUDDelegate>	{
	
	NSMutableDictionary					*routes;
	
	Route								*selectedRoute;
	
	MBProgressHUD						*HUD;

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RouteManager);
@property (nonatomic, retain)	NSMutableDictionary	*routes;
@property (nonatomic, retain)	Route	*selectedRoute;
@property (nonatomic, retain)	MBProgressHUD	*HUD;

- (void) runQuery:(Query *)query;
- (void) selectRoute:(Route *)route;

-(void)loadRouteWithIdentifier:(NSString*)routeid;
-(void)loadSavedSelectedRoute;

@end
