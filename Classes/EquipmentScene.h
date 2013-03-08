//
//  EquipmentScene.h
//  OSL
//
//  Created by James Dailey on 3/9/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface EquipmentScene : CCScene
{
}
@end

@interface EquipmentLayer : CCLayer {
	CGPoint mainRifle,mainScope, mainAmmo,selectPoint,hidden;
	int category,selected;
	CCSprite *rifleTop,*scopeTop,*ammoTop,*extra1,*extra2;
	CCLabelTTF *rifleName, *scopeName, *ammoName, *extra1Name, *extra2Name;
	CCLabelTTF *itemDescription,*itemName,*gold,*pButton,*moneyButton;
	CCMenu *menu;
	
}
-(void) badCombo;
-(void)hideAll;
-(void) updateStats;
-(void) updateDescriptions:(NSString*)d c:(int)c n:(NSString*)n u:(int)u tag:(int)tag;
@end
