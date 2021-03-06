//
//  NSData+MBBase64.h
//  RacingUK
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end
