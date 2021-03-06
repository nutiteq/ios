//
//  ImageCache.h
//  RacingUKExplorer
//
//  Created by Neil Edwards on 13/07/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#define	kIMAGECACHEIRECTORY @"imagecache"

@interface ImageCache : NSObject {
	NSMutableDictionary *imageCacheDict;
	int					maxItems;
	NSMutableArray		*cachedItems;
	
}
@property(nonatomic,retain)NSMutableDictionary *imageCacheDict;
@property(nonatomic,assign)int maxItems;
@property(nonatomic,retain)NSMutableArray *cachedItems;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ImageCache);

-(UIImage*)imageExists:(NSString*)filename ofType:(NSString*)type;
-(BOOL)saveImageToDisk:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type;
-(BOOL)storeImage:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type;
-(NSString*)fileonDiskPath:(NSString*)filename ofType:(NSString*)type;
-(NSURL*)urlForImage:(NSString*)filename ofType:(NSString*)type;
- (UIImage*)loadImageFromDocuments:(NSString*)path;
-(NSString*)userImagePath;
-(NSString*)serverImagePath;
-(BOOL)imageIsInCache:(NSString*)filename ofType:(NSString*)type;
- (void)removeAll;

-(void)removeStaleFiles:(int)interval;
@end
