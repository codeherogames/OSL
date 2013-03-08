//
//  Stats.h
//  OSL
//
//  Created by James Dailey on 3/27/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Stats : NSObject <NSCoding> {
	int w2,w3,w4,w2w,w3w,w4w,su,st,sa,he,tut,tg,mi,sux;
}
@property (readwrite, nonatomic) int w2,w3,w4,w2w,w3w,w4w,su,st,sa,he,tut,tg,mi,sux;

- (id) init: (int) w2X w3X:(int)w3X w4X:(int)w4X w2wX:(int)w2wX w3wX:(int)w3wX w4wX:(int)w4wX suX:(int)suX stX:(int)stX saX:(int)saX heX:(int)heX tutX:(int)tutX tgX:(int)tgX miX:(int)miX suxX:(int)suxX;

@end
