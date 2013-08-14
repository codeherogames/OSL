//
//  HelpScene.h
//  OSL
//
//  Created by James Dailey on 2/16/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface HelpScene : CCScene
{
	int maxPage;
	ccColor3B fontColor;
}
@end


@interface HelpLayer : CCLayer {
	CCLabelTTF *info1,*info2,*info3,*info4,*des;
	CGPoint headingPos,titlePos, text1Pos,midTextPos;
	int headingSize,textSize,titleSize,midTextSize;
	ccColor3B fontColor;
}
@property (nonatomic,assign) ccColor3B fontColor;

-(void) tocMenu;
-(void) rules;
-(void) controls;
-(void) modes;
-(void) customization;
-(void) computer;
@end
