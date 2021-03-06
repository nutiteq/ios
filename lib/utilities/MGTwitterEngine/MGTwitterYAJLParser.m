//
//  MGTwitterYAJLParser.m
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 18/02/2008.
//  Copyright 2008 Instinctive Code.

#import "MGTwitterYAJLParser.h"


@implementation MGTwitterYAJLParser

#pragma mark Callbacks

static NSString *currentKey;

int MGTwitterYAJLParser_processNull(void *ctx)
{
	id self = ctx;
	
	if (currentKey)
	{
		[self addValue:[NSNull null] forKey:currentKey];
	}
	
    return 1;
}

int MGTwitterYAJLParser_processBoolean(void * ctx, int boolVal)
{
	id self = ctx;

	if (currentKey)
	{
		[self addValue:[NSNumber numberWithBool:(BOOL)boolVal] forKey:currentKey];

		[self clearCurrentKey];
	}

    return 1;
}

int MGTwitterYAJLParser_processNumber(void *ctx, const char *numberVal, unsigned int numberLen)
{
	id self = ctx;
	
	if (currentKey)
	{
		NSString *stringValue = [[NSString alloc] initWithBytesNoCopy:(void *)numberVal length:numberLen encoding:NSUTF8StringEncoding freeWhenDone:NO];
		
		// if there's a decimal, assume it's a double
		if([stringValue rangeOfString:@"."].location != NSNotFound){
			NSNumber *doubleValue = [NSNumber numberWithDouble:[stringValue doubleValue]];
			[self addValue:doubleValue forKey:currentKey];
		}else{
			NSNumber *longLongValue = [NSNumber numberWithLongLong:[stringValue longLongValue]];
			[self addValue:longLongValue forKey:currentKey];
		}
		
		[stringValue release];
		
		[self clearCurrentKey];
	}
	
	return 1;
}

int MGTwitterYAJLParser_processString(void *ctx, const unsigned char * stringVal, unsigned int stringLen)
{
	id self = ctx;
	
	if (currentKey)
	{
		NSMutableString *value = [[[NSMutableString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding] autorelease];
		
		[value replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [value length])];
		[value replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [value length])];
		[value replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [value length])];
		[value replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [value length])];

		NSLog(@"[DEBUG] MGTwitterYAJLParser_processString");
		
		if ([currentKey isEqualToString:@"created_at"])
		{
			// we have a priori knowledge that the value for created_at is a date, not a string
			struct tm theTime;
			if ([value hasSuffix:@"+0000"])
			{
				// format for Search API: "Fri, 06 Feb 2009 07:28:06 +0000"
				strptime([value UTF8String], "%Y-%m-%d %H:%M:%S %z", &theTime);
			}
			else
			{
				// format for REST API: "Thu Jan 15 02:04:38 +0000 2009"
				strptime([value UTF8String], "%Y-%m-%d %H:%M:%S %z", &theTime);
			}
			time_t epochTime = timegm(&theTime);
			// save the date as a long with the number of seconds since the epoch in 1970
			[self addValue:[NSNumber numberWithLong:epochTime] forKey:currentKey];
			// this value can be converted to a date with [NSDate dateWithTimeIntervalSince1970:epochTime]
		}
		else
		{
			[self addValue:value forKey:currentKey];
		}
		
		[self clearCurrentKey];
	}

    return 1;
}

int MGTwitterYAJLParser_processMapKey(void *ctx, const unsigned char * stringVal, unsigned int stringLen)
{
	id self = (id)ctx;
	if (currentKey)
	{
		[self clearCurrentKey];
	}
	
	currentKey = [[NSString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding];

    return 1;
}

int MGTwitterYAJLParser_processStartMap(void *ctx)
{
	id self = ctx;
	
	[self startDictionaryWithKey:currentKey];

	return 1;
}


int MGTwitterYAJLParser_processEndMap(void *ctx)
{
	id self = ctx;
	
	[self endDictionary];

	return 1;
}

int MGTwitterYAJLParser_processStartArray(void *ctx)
{
	id self = ctx;
	
	[self startArrayWithKey:currentKey];
	
    return 1;
}

int MGTwitterYAJLParser_processEndArray(void *ctx)
{
	id self = ctx;
	
	[self endArray];
	
    return 1;
}

static yajl_callbacks sMGTwitterYAJLParserCallbacks = {
	MGTwitterYAJLParser_processNull,
	MGTwitterYAJLParser_processBoolean,
	NULL,
	NULL,
	MGTwitterYAJLParser_processNumber,
	MGTwitterYAJLParser_processString,
	MGTwitterYAJLParser_processStartMap,
	MGTwitterYAJLParser_processMapKey,
	MGTwitterYAJLParser_processEndMap,
	MGTwitterYAJLParser_processStartArray,
	MGTwitterYAJLParser_processEndArray
};

#pragma mark Creation and Destruction


+ (id)parserWithJSON:(NSData *)theJSON delegate:(NSObject *)theDelegate 
	connectionIdentifier:(NSString *)identifier requestType:(MGTwitterRequestType)reqType
	responseType:(MGTwitterResponseType)respType URL:(NSURL *)URL
	deliveryOptions:(MGTwitterEngineDeliveryOptions)deliveryOptions
{
	
	NSLog(@"[DEBUG] yajl parserWithJSON");
	
	id parser = [[self alloc] initWithJSON:theJSON 
			delegate:theDelegate 
			connectionIdentifier:identifier 
			requestType:reqType
			responseType:respType
			URL:URL
			deliveryOptions:deliveryOptions];

	return [parser autorelease];
}


- (id)initWithJSON:(NSData *)theJSON delegate:(NSObject *)theDelegate 
	connectionIdentifier:(NSString *)theIdentifier requestType:(MGTwitterRequestType)reqType 
	responseType:(MGTwitterResponseType)respType URL:(NSURL *)theURL
	deliveryOptions:(MGTwitterEngineDeliveryOptions)theDeliveryOptions
{
	if (self = [super init])
	{
		json = [theJSON retain];
		identifier = [theIdentifier retain];
		requestType = reqType;
		responseType = respType;
		URL = [theURL retain];
		deliveryOptions = theDeliveryOptions;
		delegate = theDelegate;
		
		if (deliveryOptions & MGTwitterEngineDeliveryAllResultsOption)
		{
			parsedObjects = [[NSMutableArray alloc] initWithCapacity:0];
		}
		else
		{
			parsedObjects = nil; // rely on nil target to discard addObject
		}
		
		if ([json length] <= 5)
		{
			// NOTE: this is a hack for API methods that return short JSON responses that can't be parsed by YAJL. These include:
			//   friendships/exists: returns "true" or "false"
			//   help/test: returns "ok"
			// An empty response of "[]" is a special case.
			NSString *result = [[[NSString alloc] initWithBytes:[json bytes] length:[json length] encoding:NSUTF8StringEncoding] autorelease];
			if (! [result isEqualToString:@"[]"])
			{
				NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];

				if ([result isEqualToString:@"\"ok\""])
				{
					[dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"ok"];
				}
				else
				{
					[dictionary setObject:[NSNumber numberWithBool:[result isEqualToString:@"true"]] forKey:@"friends"];
				}
				[dictionary setObject:[NSNumber numberWithInt:requestType] forKey:TWITTER_SOURCE_REQUEST_TYPE];
			
				[self _parsedObject:dictionary];

				[parsedObjects addObject:dictionary];
			}
		}
		else
		{
			// setup the yajl parser
			yajl_parser_config cfg = {
				0, // allowComments: if nonzero, javascript style comments will be allowed in the input (both /* */ and //)
				0  // checkUTF8: if nonzero, invalid UTF8 strings will cause a parse error
			};
			_handle = yajl_alloc(&sMGTwitterYAJLParserCallbacks, &cfg, NULL, self);
			if (! _handle)
			{
				return nil;
			}
			
			yajl_status status = yajl_parse(_handle, [json bytes], [json length]);
			if (status != yajl_status_insufficient_data && status != yajl_status_ok)
			{
				unsigned char *errorMessage = yajl_get_error(_handle, 0, [json bytes], [json length]);
				NSLog(@"MGTwitterYAJLParser: error = %s", errorMessage);
				[self _parsingErrorOccurred:[NSError errorWithDomain:@"YAJL" code:status userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:(char *)errorMessage] forKey:@"errorMessage"]]];
				yajl_free_error(_handle, errorMessage);
			}

			// free the yajl parser
			yajl_free(_handle);
		}
		
		// notify the delegate that parsing completed
		[self _parsingDidEnd];
	}
	
	return self;
}


- (void)dealloc
{
	[parsedObjects release];
	[json release];
	[identifier release];
	[URL release];
	
	delegate = nil;
	[super dealloc];
}

- (void)parse
{
	// empty implementation -- override in subclasses
}

#pragma mark Subclass utilities

- (void)addValue:(id)value forKey:(NSString *)key
{
	// default implementation -- override in subclasses
	
	NSLog(@"%@ = %@ (%@)", key, value, NSStringFromClass([value class]));
}

- (void)startDictionaryWithKey:(NSString *)key
{
	// default implementation -- override in subclasses
	
	NSLog(@"dictionary start = %@", key);
}

- (void)endDictionary
{
	// default implementation -- override in subclasses
	
	NSLog(@"dictionary end");
}

- (void)startArrayWithKey:(NSString *)key
{
	// default implementation -- override in subclasses
	
	NSLog(@"array start = %@", key);

	arrayDepth++;
}

- (void)endArray
{
	// default implementation -- override in subclasses
	
	NSLog(@"array end");

	arrayDepth--;
	[self clearCurrentKey];
}

- (void)clearCurrentKey{
	if(arrayDepth == 0){
		[currentKey release];
		currentKey = nil;
	}
}

#pragma mark Delegate callbacks

- (BOOL) _isValidDelegateForSelector:(SEL)selector
{
	return ((delegate != nil) && [delegate respondsToSelector:selector]);
}

- (void)_parsingDidEnd
{
	if ([self _isValidDelegateForSelector:@selector(parsingSucceededForRequest:ofResponseType:withParsedObjects:)])
		[delegate parsingSucceededForRequest:identifier ofResponseType:responseType withParsedObjects:parsedObjects];
}

- (void)_parsingErrorOccurred:(NSError *)parseError
{
	if ([self _isValidDelegateForSelector:@selector(parsingFailedForRequest:ofResponseType:withError:)])
		[delegate parsingFailedForRequest:identifier ofResponseType:responseType withError:parseError];
}

- (void)_parsedObject:(NSDictionary *)dictionary
{
	if (deliveryOptions & MGTwitterEngineDeliveryIndividualResultsOption)
		if ([self _isValidDelegateForSelector:@selector(parsedObject:forRequest:ofResponseType:)])
			[delegate parsedObject:(NSDictionary *)dictionary forRequest:identifier ofResponseType:responseType];
}


@end
