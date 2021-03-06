//
//  RemoteFileManager.m
//  Racing uk
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "RemoteFileManager.h"
#import "GlobalUtilities.h"
#import "NetRequest.h"
#import "NSDictionary+UrlEncoding.h"
#import	"NetRequest.h"
#import "NetResponse.h"
#import "AppConstants.h"

#define NSHTTPPropertyStatusCodeKey @"DB404Error"


typedef struct{
	NetRequest *request;
	int index;
	BOOL status;
}LookupResult;


@interface RemoteFileManager(Private) 

-(LookupResult)findRequestByType:(NSString*)type;
-(void)loadItemFromQueue;
-(void)load:(NetRequest*)request;
-(void)stopConnection;

@end






@implementation RemoteFileManager
SYNTHESIZE_SINGLETON_FOR_CLASS(RemoteFileManager);
@synthesize responseData;
@synthesize networkAvailable;
@synthesize myConnection;
@synthesize requestQueue;
@synthesize activeRequest;
@synthesize queueRequests;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [responseData release], responseData = nil;
    [myConnection release], myConnection = nil;
    [requestQueue release], requestQueue = nil;
    [activeRequest release], activeRequest = nil;
	
    [super dealloc];
}



-(id)init{
	
	if (self = [super init])
	{
		queueRequests=YES;
		self.requestQueue=[[NSMutableArray alloc]init];
		
		// https support
		//NSURLCredential *credentials=[NSURLCredential credentialWithUser:@"neil" password:@"password" persistence:NSURLCredentialPersistenceForSession];
//		NSURLProtectionSpace *protectionspace=[[NSURLProtectionSpace  alloc]initWithHost:@"ssss.com" port:34 protocol:https realm:@"https" authenticationMethod:NSURLAuthenticationMethodDefault];
//		[[NSURLCredentialStorage sharedCredentialStorage] setCredential:credentials forProtectionSpace:protectionspace];
//		[protectionspace release];
		
	}
	return self;
	
	
}


//
/***********************************************
 * adds a unique datid type requst to the queue, if an existing one of this type is active, it is cancelled and replaced with the new one
 ***********************************************/
//
-(void)addRequestToQueue:(NetRequest*)request{
	
	if(queueRequests==YES){

		LookupResult result=[self findRequestByType:request.dataid];

		if(result.status==NO){
			
			request.status=QUEUED;
			[requestQueue addObject:request];
			
			if([requestQueue count]==1){
				[self loadItemFromQueue];
			}
			
		}else {
			[self removeRequestFromQueue:request.dataid andResume:NO];
			
			request.status=QUEUED;
			[requestQueue addObject:request];
			[self loadItemFromQueue];
			
		}
		
	}else {
		
		BetterLog(@"[DEBUG] pre load check for existing requests: [requestQueue count]=%i",[requestQueue count]);
		
		if([requestQueue count]==1){
			
			if(activeRequest.status==INPROGRESS){
				[myConnection cancel];
				RELEASE_SAFELY(myConnection);
			}
			[requestQueue removeObjectAtIndex:0];
		}
		
		
		
		request.status=QUEUED;
		[requestQueue addObject:request];
		
		BetterLog(@"[DEBUG] post load check for existing requests: [requestQueue count]=%i",[requestQueue count]);
		
		[self loadItemFromQueue];
		
	}



}


//
/***********************************************
 * load next item in queue
 ***********************************************/
//
-(void)loadItemFromQueue{
	
	BetterLog(@"[requestQueue count]=%i",[requestQueue count]);
	
	if([requestQueue count]>0){
		
		self.activeRequest=[requestQueue objectAtIndex:0];
		activeRequest.status=INPROGRESS;
		[self load:activeRequest];
		
	}
	
	
}


// needs to support request queue

-(void)load:(NetRequest*)request{
	
	BetterLog(@"RemoteFileManager:load with %@",request.url);
		
	if(myConnection!=nil){
		[myConnection cancel];
		RELEASE_SAFELY(myConnection);
	}
	
	NetResponse *response=[[NetResponse alloc]init];
	response.dataid=activeRequest.dataid;	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:response,RESPONSE, nil];
	[response release];  // Keep and eye out here for potential leak issue
	[[NSNotificationCenter defaultCenter] postNotificationName:REMOTEDATAREQUESTED object:nil userInfo:dict];
	[dict release];
	
	
	self.myConnection = [[NSURLConnection alloc] initWithRequest:[request requestForType]  delegate:self];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	if(myConnection){
		responseData=[[NSMutableData data] retain];
		[responseData setLength:0];
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	
	
	if ([response respondsToSelector:@selector(statusCode)])
		{
			int statusCode = [((NSHTTPURLResponse *)response) statusCode];
			if (statusCode >= 400)
			{
				
				BetterLog(@"didReceiveResponse: server.statusCode %i",statusCode);
				
				[myConnection cancel];  // stop connecting; no more delegate messages
				NSDictionary *errorInfo
				= [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
													  NSLocalizedString(@"Server returned status code %d",@""),
													  statusCode]
											  forKey:NSLocalizedDescriptionKey];
				NSError *statusError
				= [NSError errorWithDomain:NSHTTPPropertyStatusCodeKey
									  code:statusCode
								  userInfo:errorInfo];
				[self connection:myConnection didFailWithError:statusError];
			}
		}

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
	
    [responseData appendData:data];
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:@"RemoteFileManagerLoadedBytes",@"type",responseData,@"value",nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteFileManagerLoadedBytes" object:nil userInfo:dict];
	RELEASE_SAFELY(dict);
	
}




- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	BetterLog(@"");
	
	networkAvailable=YES;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NetResponse *response=[[NetResponse alloc]init];
	response.dataid=activeRequest.dataid;
	response.requestid=activeRequest.requestid;
	response.responseData=responseData;
	
	[self removeRequestFromQueue:activeRequest.dataid andResume:YES];
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:networkAvailable],@"networkStatus",response,@"response", nil];
	[response release];  // keep an eye out here for potential leak issue later ???
	[[NSNotificationCenter defaultCenter] postNotificationName:REMOTEFILELOADED object:nil userInfo:dict];
	[dict release]; 
	
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	networkAvailable=NO;
	
	NetResponse *response=[[NetResponse alloc]init];
	response.dataid=activeRequest.dataid;
	response.requestid=activeRequest.requestid;
	response.responseData=nil;
	response.error=REMOTEFILEFAILED;
	
	[self removeRequestFromQueue:activeRequest.dataid andResume:YES];
	
	BetterLog(@"RemoteFileManager.didFailWithError: %@", [error localizedDescription] );
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:networkAvailable],@"networkStatus",response,@"response", nil];
	[response release];
	[[NSNotificationCenter defaultCenter] postNotificationName:REMOTEFILEFAILED object:nil userInfo:dict];
	[dict release];
	
	[responseData release];
	
	
	
	
}


//
/***********************************************
 * @description			Called for https connections if no stored credentials were found in the NSURLCredentialStorage singleton
 ***********************************************/
//
-(void)connection:(NSURLConnection *)connectiondidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
	BetterLog(@"");
	
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:@"name"
                                                 password:@"password"
                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
       // [self showPreferencesCredentialsAreIncorrectPanel:self];
    }
}
								
								
	
-(LookupResult)findRequestByType:(NSString*)type{
	
	LookupResult result={nil,-1,NO};
	
	for(int i=0;i<[requestQueue count];i++){
		NetRequest *request=[requestQueue objectAtIndex:i];
		if ([request.dataid isEqualToString:type]) {
			result.request=request;
			result.index=i;
			result.status=YES;
			break;
		}
	}
	
	return result;
	
}
							


//
/***********************************************
 * remote queue item cancel method
 ***********************************************/
//
-(void)cancelRequest:(NSNotification*)notification{
	
	NSDictionary *dict=[notification userInfo];
	
	NSString *dataid=[dict objectForKey:DATATYPE];
	
	[self removeRequestFromQueue:dataid andResume:YES];
	
}


-(void)cancelAllRequests{
	
	[requestQueue removeAllObjects];
	[self stopConnection];
}


//
/***********************************************
 * removes and cancels item of type and resumes queue if required
 ***********************************************/
//
-(void)removeRequestFromQueue:(NSString*)type andResume:(BOOL)resume{
	
	LookupResult result=[self findRequestByType:type];
	
	if(result.status==YES){
		
		if(result.request.status==INPROGRESS){
			
			[self stopConnection];
			
		}
		
		[requestQueue removeObjectAtIndex:result.index];

	}
	
	if(resume==YES){
		[self loadItemFromQueue];
	}
		
}



-(void)stopConnection{
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[myConnection cancel];
	RELEASE_SAFELY(myConnection);
	
}



@end
