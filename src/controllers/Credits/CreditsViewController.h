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

//  Credits.h
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import <UIKit/UIKit.h>


@interface CreditsViewController : UIViewController <UIWebViewDelegate> {
	
			UIWebView				*webView;
			UIAlertView				*failAlert;
	
	IBOutlet	UIToolbar			*controlBar;
	
	IBOutlet UIBarButtonItem		*stopLoadingButton;
	IBOutlet UIBarButtonItem		*refreshButton;
	IBOutlet UIBarButtonItem		*goBackButton;
	IBOutlet UIBarButtonItem		*goForwardButton;
	UIBarButtonItem					*activityBarItem;
	UIActivityIndicatorView			*activityIndicator;
	
	BOOL							pageLoaded;
}

@property (nonatomic, retain)		IBOutlet UIWebView				* webView;
@property (nonatomic, retain)		IBOutlet UIAlertView				* failAlert;
@property (nonatomic, retain)		IBOutlet UIToolbar				* controlBar;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* stopLoadingButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* refreshButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* goBackButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* goForwardButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem				* activityBarItem;
@property (nonatomic, retain)		IBOutlet UIActivityIndicatorView				* activityIndicator;
@property (nonatomic)		BOOL				 pageLoaded;

-(void)updateUIState:(NSString*)state;
-(IBAction)stopLoading:(id)sender;
-(IBAction)refreshWebView:(id)sender;
-(IBAction)goForwardButtonSelected:(id)sender;
-(IBAction)goBackButonSelected:(id)sender;
-(void)showActivityIndicator:(BOOL)show;
@end
