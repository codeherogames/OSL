//
//  BigTouchMenuItem.m
//  OSL
//
//  Created by James Dailey on 2/12/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "JDMenuItem.h"


@implementation JDMenuItem
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s
{
	self = [super itemFromNormalImage:value selectedImage:value2 target:t selector:s];
	return self;
}

-(void) activate
{
	[[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[super activate];
}

/*-(CGRect) rect
{
	return CGRectMake( position_.x - contentSize_.width*anchorPoint_.x,
					  position_.y - contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);	
}*/

@end
