//
//  BonusSprite.m
//  OSL
//
//  Created by James Dailey on 8/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BonusSprite.h"


@implementation BonusSprite

-(void) updateLabel:(NSString*) l {
    if (!bonusLabel) {
        bonusLabel = [CCLabelBMFont labelWithString:l fntFile:@"bombard.fnt"];
        [bonusLabel setPosition:ccp(self.contentSize.width/2,self.contentSize.height/2)];
        bonusLabel.color = ccGREEN;
        [self addChild:bonusLabel z:1];
    }
    self.visible = YES;
    [bonusLabel setString:l];
}

-(void) hide {
    self.visible=NO;
}
@end
