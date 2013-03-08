//
//  glassSlider.h
//  PixelSniper
//
//  Created by James Dailey on 1/26/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "AppDelegate.h"

@interface GlassSlider : CCSprite {
	CCAction *actionIn,*actionOut;
	int status,called;
	CCLabelTTF *l1,*l2,*l3;
}
@property (nonatomic, retain) CCAction *actionIn,*actionOut;
@property(nonatomic, readwrite) int status,called;
@property(nonatomic, retain) CCLabelTTF *l1,*l2,*l3;

- (id) initWithFile: (NSString*) s;
- (void) initActions;
- (void) addButtons: (NSMutableArray*) n;
- (void) slideOut;
- (void) slideIn;
@end
