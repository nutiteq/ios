//
//  RKUserSettingsManager.m
//  RacingUK
//
//  Created by neil on 10/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "UserSettingsManager.h"
#import "SynthesizeSingleton.h"
#import "GlobalUtilities.h"

static NSString *const ID = @"StyleManager";


@interface UserSettingsManager(Private)

- (void) loadUserSettings:(NSString *)aKey;
- (void) loadApplicationState;
-(BOOL)copyApplicationState;
- (NSString*) userStatePath;
- (NSString*) bundleStatePath;
-(BOOL)copyUserStateToUser;

@end


@implementation UserSettingsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(UserSettingsManager);
@synthesize settings;
@synthesize userState;
@synthesize userStateWritable;
@synthesize delegate;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [settings release], settings = nil;
    [userState release], userState = nil;
    delegate = nil;
	
    [super dealloc];
}




-(id)init{
	if (self = [super init])
	{
		userStateWritable=NO;
		[self loadUserSettings:kSettingDataIntervalKey];
		[self loadApplicationState];
	}
	return self;
}



// loads any user defaults
// pre initialises the Settings properties if user hasnt opened Settings app since first 
// install. opens root.plist and sets the user prefs to the default set
- (void) loadUserSettings:(NSString *)aKey{
	
	settings = [NSUserDefaults standardUserDefaults]; // does not need releasing as this static method
	
	// if settings doesnt contain a known key then this must be 1st run
	if (![settings stringForKey:aKey]){
		
		// The settings haven't been initialized, so manually init them based
		// the contents of the the settings bundle
		NSString *bundle = [[[NSBundle mainBundle] bundlePath]
							stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
		NSDictionary *plist = [[NSDictionary dictionaryWithContentsOfFile:bundle]
							   objectForKey:@"PreferenceSpecifiers"];
		NSMutableDictionary *defaults = [[NSMutableDictionary alloc]init];
		
		// Loop through the bundle settings preferences and pull out the key/default pairs
		for (NSDictionary* setting in plist){
			
			NSString *key = [setting objectForKey:@"Key"];
			if (key){
				[defaults setObject:[setting objectForKey:@"DefaultValue"] forKey:key];
			}
		}
		
		// Persist the newly initialized default settings and reload them
		[settings setPersistentDomain:defaults forName:[[NSBundle mainBundle] bundleIdentifier]];
		settings = [NSUserDefaults standardUserDefaults];
		
		[defaults release];
	}
	
}







//
/***********************************************
 * USER STATE METHODS
 ***********************************************/
//

//
/***********************************************
 * @description			Return the users navigation context Array
 ***********************************************/
//
-(NSArray*)navigation{
	return [userState objectForKey:kSTATENAVIGATION];
}


//
/***********************************************
 * @description			returns index of the saved context section
 ***********************************************/
//
-(int)getSavedSection{
	
	int index=0;
	
	NSArray *navigation=[userState objectForKey:kSTATENAVIGATION];
	for(int i=0;i<[navigation count]; i++){
		NSDictionary *navitem=[navigation objectAtIndex:i];
		if([[navitem objectForKey:@"id"] isEqualToString:[userState objectForKey:@"context"]]){
			index=i;
			break;
		}
	}
	return index;
	
}

//
/***********************************************
 * @description			set saved context to selected tab bar item id
 ***********************************************/
//
-(void)setSavedSection:(NSString*)type{	
	
	NSArray *navigation=[userState objectForKey:kSTATENAVIGATION];
	for(int i=0;i<[navigation count]; i++){
		NSDictionary *navitem=[navigation objectAtIndex:i];
		if([[navitem objectForKey:@"title"] isEqualToString:type]){
			[userState setObject:[navitem objectForKey:@"id"] forKey:@"context"];
			[self saveApplicationState];
			break;
		}
	}
}


//
/***********************************************
 * @description			Returns the users active navigation context value
 ***********************************************/
//
-(NSString*)context{
	return [userState objectForKey:kSTATECONTEXT];
}


-(id)userDefaultForType:(NSString*)key{
	return [settings objectForKey:key];
}


//
/***********************************************
 * @description			If a user has requested cache reset we reset the flag back to NO so it doesnt occur again unless re-requested
 ***********************************************/
//
-(void)resetCacheReset{
	[settings setBool:NO forKey:kSettingDataReset];
	[settings synchronize];
}



#pragma mark Application state methods


//
/***********************************************
 * @description			Loads user configurable state plist, if cant be found load the default Bundle one
 ***********************************************/
//
- (void)loadApplicationState{
	
	userStateWritable=[self copyApplicationState];
		
	if (userStateWritable==YES) {
		userState=[[NSMutableDictionary alloc] initWithContentsOfFile:[self userStatePath]];
	}else {
		userState=[[NSMutableDictionary alloc] initWithContentsOfFile:[self bundleStatePath]];
	}

}

//
/***********************************************
 * rearrange userstate dict to match navigationController array
 ***********************************************/
//
-(void)updateNavigationControllerState:(NSArray*)controllers{
	
	NSMutableArray *newcontrollers=[[NSMutableArray alloc]init];
	
	NSArray *navigation=[userState objectForKey:kSTATENAVIGATION];
	
	for (int i=0; i<[controllers count];i++) {
		
		UIViewController *navcontroller=[controllers objectAtIndex:i];
		
		for(int n=0;n<[navigation count];n++){
			NSDictionary *navitem=[navigation objectAtIndex:n];
			if ([navcontroller.tabBarItem.title isEqualToString:[navitem objectForKey:@"title"]]) {
				[newcontrollers addObject:navitem];
				break;
			}
			
		}
		
	}
	
	[userState setObject:newcontrollers forKey:kSTATENAVIGATION];
	[newcontrollers release];
	
}

//
/***********************************************
 * @description			Save the users current state
 ***********************************************/
//
-(void)saveApplicationState{
	if(userStateWritable==YES){
		[userState writeToFile:[self userStatePath] atomically:YES];
	}
}


//
/***********************************************
 * @description			Assess wether to update the state file from the bundel on 1st run of a new app version
 ***********************************************/
//
-(BOOL)copyApplicationState{

	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError *error=nil;
	BOOL appstateexists = [fileManager fileExistsAtPath:[self userStatePath]];

	// First, copy db to user bundle
	if(appstateexists==NO){
		// do copy, if errors, rename backup back
		if(![fileManager copyItemAtPath:[self bundleStatePath] toPath:[self userStatePath] error:&error]){
			BetterLog(@"[ERROR] BUNDLE TO USER FILE COPY ERROR %@ %@",error, [error userInfo]);
			appstateexists=NO;
		}else {
			appstateexists=YES;
		}
	}else {
		
		NSMutableDictionary *bstate=[[NSMutableDictionary alloc] initWithContentsOfFile:[self bundleStatePath]];
		NSMutableDictionary *ustate=[[NSMutableDictionary alloc] initWithContentsOfFile:[self userStatePath]];
		
		NSString *userversion=[ustate objectForKey:@"appVersion"];
		
		CGFloat bundlefloat=[[bstate objectForKey:@"appVersion"] floatValue];
		CGFloat userfloat=[[ustate objectForKey:@"appVersion"] floatValue];

		
		if(userversion!=nil){
			
			if(bundlefloat>userfloat){
				appstateexists=[self copyUserStateToUser];
			}else {
				appstateexists=YES;
			}

		}else {
			appstateexists=[self copyUserStateToUser];
		}
		
		[bstate release];
		[ustate release];

		
	}


	return appstateexists;

}


//
/***********************************************
 * @description			Copy the bundle included user state plist to the users documents dir
 ***********************************************/
//
-(BOOL)copyUserStateToUser{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError *error=nil;
	
	[fileManager removeItemAtPath:[self userStatePath] error:nil];
	
	if(![fileManager copyItemAtPath:[self bundleStatePath] toPath:[self userStatePath] error:&error]){
		BetterLog(@"[ERROR] BUNDLE TO USER FILE COPY ERROR %@ %@",error, [error userInfo]);
		return NO;
	}else {
		return YES;
	}
}

//
/***********************************************
 * @description			Return users Doc dir
 ***********************************************/
//
- (NSString*) userStatePath{	
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* docsdir=[paths objectAtIndex:0];
	return [docsdir stringByAppendingPathComponent:kSTATEFILE];
}

//
/***********************************************
 * @description			Return the Bundle state file path
 ***********************************************/
//
- (NSString*) bundleStatePath{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kSTATEFILE];
}



@end
