    //
//  PhotoMapImageLocationViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoMapImageLocationViewController.h"
#import "AppConstants.h"
#import "GradientView.h"

@interface PhotoMapImageLocationViewController(Private) 

-(void)updateContentSize;
-(void)updateImageSize;
-(void)createPersistentUI;
-(void)createNavigationBarUI;
-(void)createNonPersistentUI;
-(IBAction)backButtonSelected:(id)sender;

@end


@implementation PhotoMapImageLocationViewController
@synthesize dataProvider;
@synthesize navigationBar;
@synthesize scrollView;
@synthesize viewContainer;
@synthesize imageView;
@synthesize imageLabel;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [navigationBar release], navigationBar = nil;
    [scrollView release], scrollView = nil;
    [viewContainer release], viewContainer = nil;
    [imageView release], imageView = nil;
    [imageLabel release], imageLabel = nil;
	
    [super dealloc];
}






//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	
}

-(void)ImageDidLoadWithImage:(UIImage*)image{
	
	[viewContainer refresh];
	[self updateContentSize];
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)createPersistentUI{
	
	[(GradientView*) self.view setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
	
	viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.alignMode=BUCenterAlignMode;
	viewContainer.fixedWidth=YES;
	viewContainer.paddingTop=20;
	viewContainer.itemPadding=20;
		
	imageView=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 240)];
	imageView.delegate=self;
	imageView.cacheImage=NO;
	[viewContainer addSubview:imageView];
	
	imageLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	imageLabel.font=[UIFont systemFontOfSize:13];
	imageLabel.textColor=UIColorFromRGB(0x666666);
	imageLabel.hasShadow=YES;
	imageLabel.multiline=YES;
	[viewContainer addSubview:imageLabel];
	
	[scrollView addSubview:viewContainer];
	
	[self updateContentSize];
	
	[self createNavigationBarUI];
}


-(void)createNavigationBarUI{
	
	UIBarButtonItem *back = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(backButtonSelected:)]
							 autorelease];
	UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:@"Photomap"] autorelease];
	[navigationItem setRightBarButtonItem:back];
	[self.navigationBar pushNavigationItem:navigationItem animated:NO];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	imageView.frame=CGRectMake(0, 0, SCREENWIDTH, 240);
	[viewContainer refresh];
	[self updateContentSize];
	
}



//
/***********************************************
 * @description			Content Loading
 ***********************************************/
//

- (void) loadContentForEntry:(PhotoEntry *)photoEntry{
	
	
	self.dataProvider=photoEntry;
	
	self.navigationBar.topItem.title = [NSString stringWithFormat:@"Photo #%@", [dataProvider csid]];
	
	imageLabel.text=[dataProvider caption];
	
	[imageView loadImageFromString:[dataProvider bigImageURL]];
	
}


//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)backButtonSelected:(id)sender{
	
	[imageView cancel];
	[self dismissModalViewControllerAnimated:YES];
	
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//


-(void)updateContentSize{
	
	[scrollView setContentSize:CGSizeMake(SCREENWIDTH, viewContainer.height)];
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
