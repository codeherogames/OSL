//
//  GoldScene.h
//  OSL
//
//  Created by James Dailey on 3/14/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface GoldScene : CCScene {}
@end

@interface GoldLayer : CCLayer {
	CCLabelTTF *gold;
	CCLabelTTF *message;
	CCMenu *goldMenu;
	CCAction *fadeAction;
}
- (void)showProducts;
-(void) toggleMenu:(int)i;
@end