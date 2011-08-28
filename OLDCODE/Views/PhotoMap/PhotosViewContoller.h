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

//  Photos.h
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AddPhoto.h"
#import "PhotoInfo.h"
#import "PhotoMapImageLocationViewController.h"
#import "AccountViewController.h"
@class AssetGroupTable;
@class PhotoAsset;

@interface PhotosViewContoller : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate,
CLLocationManagerDelegate, UIAlertViewDelegate,
UITextViewDelegate, UIActionSheetDelegate> {
	UIImageView *selected;
	UIBarButtonItem *camera;
	UIBarButtonItem *library;
	UIBarButtonItem *caption;
	UIBarButtonItem *info;
	UIBarButtonItem *send;
	UIBarButtonItem *accuracy;
	UIBarButtonItem *del;
	
	UIToolbar *toolbar;
	UIToolbar *photoToolbar;
	
	UINavigationBar *captionBar;
	UIBarButtonItem *captionDone;
	
	AccountViewController *loginView;
	
	PhotoMapImageLocationViewController *preview;
	
	CLLocationManager			*locationManager;
	CLLocation					*location;
	BOOL						locationManagerIsLocating;
	
	UIAlertView *alert;
	UIAlertView *deleteAlert;
	UIAlertView *emailAlert;
	UIAlertView *errorAlert;
	
	
	AddPhoto *addPhoto;
	PhotoInfo *photoInfo;
	UIActionSheet *photoAction;
	
	UITextView *captionText;
	NSString *currentCaption;
	NSString *photoId;
	
	BOOL sendInProgress;
	BOOL pickedCategory;
	BOOL	subviewWasActive;
	
	
	NSString *bigImageURL;//uploaded.
	
	//this is the thing that tells us we really have an image.
	PhotoAsset *photoAsset;
	
	AssetGroupTable *assetGroupTable;
	UINavigationController *navigateLibrary;
	
	UIImagePickerController *picker;
	
	NSString *lastUploadId;
	
	//these hold data being saved.
	NSData *jpegData;
	CGDataProviderRef jpegDataProvider;
	CGImageRef imageRef;
}

@property (nonatomic, retain) IBOutlet UIImageView *selected;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *camera;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *library;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *caption;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *info;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *send;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *accuracy;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *del;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIToolbar *photoToolbar;
@property (nonatomic, retain) IBOutlet UINavigationBar	*captionBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *captionDone;
@property (nonatomic, retain) IBOutlet UITextView *captionText;

@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic, retain) UIAlertView *deleteAlert;
@property (nonatomic, retain) UIAlertView *emailAlert;
@property (nonatomic, retain) UIAlertView *errorAlert;

@property (nonatomic, copy) NSString *currentCaption;

@property (nonatomic, retain) CLLocation *location;

@property (nonatomic, retain) AccountViewController *loginView;
@property (nonatomic, retain) AddPhoto *addPhoto;
@property (nonatomic, retain) PhotoInfo *photoInfo;
@property (nonatomic, retain) UIActionSheet *photoAction;

@property (nonatomic, retain) PhotoMapImageLocationViewController *preview;
@property (nonatomic, copy) NSString *bigImageURL;
@property (nonatomic, copy) NSString *photoId;

@property (nonatomic, retain) UINavigationController *navigateLibrary;
@property (nonatomic, retain) AssetGroupTable *assetGroupTable;
@property (nonatomic, retain) PhotoAsset* photoAsset;

@property (nonatomic, retain) UIImagePickerController *picker;

@property (nonatomic, copy) NSString *lastUploadId;
@property (nonatomic, retain) NSData *jpegData;
@property (nonatomic, assign) BOOL locationManagerIsLocating;
@property (nonatomic, assign) BOOL subviewWasActive;


- (IBAction) didCamera;
- (IBAction) didCaption;
- (IBAction) didInfo;
- (IBAction) didSend;
- (IBAction) didDelete;

- (IBAction) didCaptionDone;
- (IBAction) didCaptionCancel;

-(void)enableButtons:(BOOL)enable;

- (void)stopUpdatingLocation:(NSString *)state;

@end