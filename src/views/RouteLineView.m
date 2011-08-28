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

//  RouteLineView.m
//  CycleStreets
//
//  Created by Alan Paxton on 17/05/2010.
//

#import "RouteLineView.h"
#import "CSPoint.h"
#import <math.h>

static NSInteger MAX_DIST = 10;

@implementation RouteLineView

@synthesize pointListProvider;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

//estimate on x,y only. sum these. Close enough for our "when to split" purposes.
- (NSInteger) dist:(CGPoint)p1 to:(CGPoint)p2 {
	return abs(p2.x - p1.x) + abs(p2.y - p1.y);
}

//points are far apart, interpolate so we can plot close to the edge.
- (NSArray *) interpolateFrom:(CGPoint)p1 to:(CGPoint)p2 {
	NSInteger dist = [self dist:p1 to:p2];
	NSInteger num =  dist / MAX_DIST;
	NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 0; i < num; i++) {
		CGPoint p;
		p.x = p1.x + i * (p2.x - p1.x) / num;
		p.y = p1.y + i * (p2.y - p1.y) / num;
		CSPoint *csPoint = [[CSPoint alloc] init];
		csPoint.p = p;
		[results addObject:csPoint];
		[csPoint release];
	}
	return results;
}

//interpolate when points cross boundaries.
- (NSArray *) interpolate:(NSArray *)points {
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	CSPoint *prev = nil;
	for (CSPoint *point in points) {
		if (prev != nil) {
			NSArray *between = [self interpolateFrom:prev.p to:point.p];
			[result addObjectsFromArray:between];
		}
		[result addObject:point];
		prev = point;
	}
	return result;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth( ctx, 4.0);
	CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.8 green:0.2 blue:1.0 alpha:0.8].CGColor);
	
	NSArray *points = [pointListProvider pointList];
	
	bool first = YES;
	for (CSPoint *point in points) {
		if (first) {
			CGContextMoveToPoint(ctx, point.p.x, point.p.y);
			first = NO;
		} else {
			CGContextAddLineToPoint(ctx, point.p.x, point.p.y);
		}
	}
	
	CGContextStrokePath(ctx);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)dealloc {
	self.pointListProvider = nil;
	
    [super dealloc];
}


@end
