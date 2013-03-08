//
//  Radio.h
//  PixelSniper
//
//  Created by James Dailey on 1/29/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "Enemy.h"

@interface Radio : Enemy {
	CCAnimation *animateMusic;
	id actionMusic;
}
- (id) initWithFile: (NSString*) s l:(CCNode*)l;
@property (nonatomic, retain) CCAnimation *animateMusic;
@property (nonatomic, retain) id actionMusic;
- (void) randomPosition;
@end
