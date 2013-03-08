//
//  ComputerScene.h
//  OSL
//
//  Created by James Dailey on 3/9/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

@interface ComputerScene : CCScene
{
}
-(void) showDescription:(NSString*)d;
@end

@interface ComputerLayer : CCLayer {
	CCLabelTTF *info1,*info2,*info3,*info4,*des;
}
@property (nonatomic,retain) CCLabelTTF *info1,*info2,*info3,*info4,*des;

-(void) showDescription:(NSString*)d;
@end