/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  PhotoMap.h
//  CycleStreets
//
//  Created by Alan Paxton on 06/06/2010.
//

#import <UIKit/UIKit.h>
#import "MapLocationSearchViewController.h"
#import "RMMapViewDelegate.h"
#import "BlueCircleView.h"
#import "MBProgressHUD.h"
@class CycleStreets;
@class Location;
@class PhotoMapImageLocationViewController;
@class InitialLocation;

@interface PhotoMapViewController : UIViewController
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, LocationProvider,MBProgressHUDDelegate> {
	
	
	RMMapView *mapView;				//map of current area
	BlueCircleView *blueCircleView;	//overlay GPS location
	UILabel *attributionLabel;
	
	CLLocationManager *locationManager; //move out of this class into app, or app sub, if/when we generalise.
	PhotoMapImageLocationViewController *locationView;			//the popup with the contents of a particular location (photomap etc.)
	CLLocation *lastLocation;		//the last one
	
	MBProgressHUD			*progressHud;
	
	
	InitialLocation *initialLocation;
	UIBarButtonItem *locationButton;
	UIBarButtonItem *showPhotosButton;
	MapLocationSearchViewController *mapLocationSearchView;			//the search popup
	
	//Welcome
	UITextView *introView;
	UIButton *introButton;
	
	NSMutableArray *photoMarkers;
	
	BOOL photomapQuerying;
	BOOL showingPhotos;
	BOOL locationManagerIsLocating;
	BOOL locationWasFound;
}

@property (nonatomic, retain)		RMMapView				* mapView;
@property (nonatomic, retain)		BlueCircleView				* blueCircleView;
@property (nonatomic, retain)		IBOutlet UILabel				* attributionLabel;
@property (nonatomic, retain)		CLLocationManager				* locationManager;
@property (nonatomic, retain)		PhotoMapImageLocationViewController				* locationView;
@property (nonatomic, retain)		CLLocation				* lastLocation;
@property (nonatomic, retain)		MBProgressHUD				* progressHud;
@property (nonatomic, retain)		InitialLocation				* initialLocation;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* locationButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* showPhotosButton;
@property (nonatomic, retain)		MapLocationSearchViewController				* mapLocationSearchView;
@property (nonatomic, retain)		IBOutlet UITextView				* introView;
@property (nonatomic, retain)		IBOutlet UIButton				* introButton;
@property (nonatomic, retain)		NSMutableArray				* photoMarkers;
@property (nonatomic)		BOOL				 photomapQuerying;
@property (nonatomic)		BOOL				 showingPhotos;
@property (nonatomic)		BOOL				 locationManagerIsLocating;
@property (nonatomic)		BOOL				 locationWasFound;


- (IBAction) didZoomIn;
- (IBAction) didZoomOut;
- (IBAction) didLocation;
- (IBAction) didShowPhotos;
- (IBAction) didSearch;

- (IBAction) didIntroButton;

- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw;

- (void)stopShowingPhotos;
- (void)startShowingPhotos;
- (void)stopUpdatingLocation:(NSString *)state;
- (void)startlocationManagerIsLocating;
- (void)stoplocationManagerIsLocating;

-(void)showProgressHud:(BOOL)show;
-(void)removeHUD;

- (void) requestPhotos;
- (void) clearPhotos;

@end
