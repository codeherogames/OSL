//
//  TutorialScene.m
//  OSL
//
//  Created by James Dailey on 4/22/11.
//  Copyright 2011 James Dailey. All rights reserved.
//

#import "TutorialScene.h"
#import "MyToggle.h"
#import "MyMenuButton.h"
#import "ChildMenuButton.h"
#import "MenuScene.h"
#import "PopupLayer.h"
#import "MenuScene.h"
#import "Radio.h"

enum {
	kBackgroundLayer = 5000,
	kMidgroundLayer = 5001,
	kForegroundLayer = 5002,	
	kScopeLayer = 5003,
	kControlLayer = 5004,
	kSkylineLayer = 5005,
	kPauseLayer = 5006,
	kButtonMenu = 6000,
};

@implementation TutorialScene
- (id) init {
    self = [super init];
    if (self != nil) {
		CCLOG(@"TutorialScene tutorialState:%i",[AppDelegate get].tutorialState);
		[AppDelegate get].money = 0;
		if ([AppDelegate get].tutorialState == 3) {
			[self popup:@"This is the basic screen layout.  You are looking through a scope with Zoom and Fire buttons on the bottom right.  Your Wrist Computer is on the left.  Your Recon, which show the latest actions taken, is on the top right.  These items will be explained within this tutorial.  Press the Continue button." t:@"Basic Layout"];
		}
		else {
			[AppDelegate get].tutorialState-=2;
			[self popup:@"Welcome back.  Let's continue your training." t:@"Continue Training"];
		}
    }
    return self;
}

-(void) popup: (NSString*) m t:(NSString*)t {
	CCLOG(@"popup");
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:m t:t] autorelease];
	[self addChild:popup z:10];
}

-(void) popupClicked {
	[(TutorialLayer*) [self getChildByTag:kBackgroundLayer] popupClicked];
}

-(void) addLayers {
	[self addChild:[SkylineLayer node] z:0 tag:kSkylineLayer];
	[self addChild:[TutorialControlLayer node] z:5 tag:kControlLayer];
	[self addChild:[TutorialLayer node] z:1 tag:kBackgroundLayer];
	[self addChild:[ForegroundLayer node] z:1 tag:kForegroundLayer];
	[self addChild:[MidgroundLayer node] z:2 tag:kMidgroundLayer];
	[self addChild:[ScopeLayer node] z:4 tag:kScopeLayer];
	[AppDelegate get].bgLayer = (BackgroundLayer*) [self getChildByTag:kBackgroundLayer];
	
}

- (void) dealloc {
	CCLOG(@"dealloc TutorialScene"); 
	[super dealloc];
}
@end

@implementation TutorialLayer
-(id) init {
    self = [super init];
    if (self != nil) {	
		//[self nextStep];
		lastState = -1;
		successCount = 0;
		targetCount = 0;	
	}
	return self;
}

-(void) nextStep {
	//self.position = ccp(-pres.position.x,pres.position.y);
	[self setZoom2:[AppDelegate get].minZoom];
	[(ForegroundLayer*) [self.parent getChildByTag:kForegroundLayer] setZoom:[AppDelegate get].minZoom];
	[(MidgroundLayer*) [self.parent getChildByTag:kMidgroundLayer] setZoom:[AppDelegate get].minZoom];
	[(SkylineLayer*) [self.parent getChildByTag:kSkylineLayer] setZoom:[AppDelegate get].minZoom];
	CCLOG(@"NextStep tutorialState:%i,lastState:%i",[AppDelegate get].tutorialState,lastState);
	if (lastState != [AppDelegate get].tutorialState) {
		[[NSUserDefaults standardUserDefaults] setInteger:[AppDelegate get].tutorialState forKey:@"tut"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	//[AppDelegate get].stats.tut = [AppDelegate get].tutorialState;
	//[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
	if ([AppDelegate get].tutorialState == 5) {
		[self popup:@"There is a red enemy Agent on top of the building on the right.  Get him in your sights by placing your left thumb on the screen anywhere and drag up and right.  Try not to swipe or lift your thumb.  When you have the Agent's head in your sights, shoot him by pressing the fire button with your right thumb." t:@"Movement and Headshots"];
		if (lastState != [AppDelegate get].tutorialState) {
			Sniper *enemySniper = [[Sniper alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];	 
			enemySniper.color = ccRED;
			enemySniper.position = ccp(BUILDING2LEFT+100,ROOF);
			
			CCSprite *pointer = [CCSprite spriteWithFile:@"arrow1.png"];
			pointer.position=ccp(enemySniper.position.x-enemySniper.contentSize.width/2-4,enemySniper.position.y+enemySniper.contentSize.height/2-10);
			pointer.scale=0.3;
			[self addChild:pointer z:enemySniper.zOrder tag:555];
			
			successCount = 0;
			targetCount = 1;
		}
	}
	else if ([AppDelegate get].tutorialState == 6) {
		[self removeChildByTag:555 cleanup:YES];
		[self popup:@"Perfect!  All Agents are red with sunglasses.  Citizens look the same except they don't wear sunglasses.  Be sure not to shoot them - as collateral damage is prohibited.\n\nNow press the Zoom button with your right thumb to zoom in.  Then the Zoom button again to zoom out." t:@"Zoom"];
		if (lastState != [AppDelegate get].tutorialState) {
		successCount = 0;
		targetCount = 2;
		}
	}
	else if ([AppDelegate get].tutorialState == 7) {
		[self popup:@"Besides a headshot, you can eliminate enemy Agents by shooting them in the body 3 times.  The Agent is back in the same spot.  Kill him by body shots." t:@"Body Shots"];
		if (lastState != [AppDelegate get].tutorialState) {
			self.position = ccp(-pres.position.x,pres.position.y);
			Enemy *enemySniper = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];	 
			enemySniper.color = ccRED;
			enemySniper.position = ccp(BUILDING2LEFT+100,ROOF);
			
			CCSprite *pointer = [CCSprite spriteWithFile:@"arrow1.png"];
			pointer.position=ccp(enemySniper.position.x-enemySniper.contentSize.width/2-8,enemySniper.position.y-6);
			pointer.scale=0.3;
			[self addChild:pointer z:enemySniper.zOrder tag:555];
			
			three = [CCLabelTTF labelWithString:@"3x" fontName:[AppDelegate get].clearFont fontSize:22];
			three.position=ccp(pointer.position.x-6,pointer.position.y+8+(pointer.contentSize.height/2 * pointer.scale));
			three.color=ccBLACK;
			[self addChild:three z:enemySniper.zOrder tag:666];
			
			successCount = 0;
			targetCount = 1;
		}
	}
	else if ([AppDelegate get].tutorialState == 8) {
		[self removeChildByTag:555 cleanup:YES];
		[self removeChildByTag:666 cleanup:YES];
		[self popup:@"Your wrist computer on the left launches attacks against your opponent.  Since you are a mercenary, you get paid for your time. As you earn in-game money, the attacks available to you are increasingly devastating to your opponent.  Buttons are disabled when you don't have enough money to launch them.  You can also earn money from kill streaks." t:@"Wrist Computer - Overview"];
		successCount = 0;
		targetCount = 0;
	}
	else if ([AppDelegate get].tutorialState == 9) {
		[self popup:@"When you click a button, it will slide out 3 attack options.  You can then choose an attack from one of the choices which will launch on your opponent's screen.  In Sandbox Mode, the attacks will show on your screen so you can see what each one does." t:@"Wrist Computer - Buttons"];
		if (lastState != [AppDelegate get].tutorialState) {
		successCount = 0;
		targetCount = 0;
		}
	}
	else if ([AppDelegate get].tutorialState == 10) {
		[self popup:@"Let's launch a foot Agent.  Click on the bottom button (person icon) and see the glass slider come out.  Then choose the white icon that looks like a person.  During a match, this will launch a foot Agent that emerges on the street from either direction.  On the top right, Recon will indicate that you launched an Agent." t:@"Wrist Computer - Tier 1"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T1;
		[[[AppDelegate get].m1.childButtons objectAtIndex:0] enable];
		successCount = 0;
		targetCount = 1;
		}
	}
	else if ([AppDelegate get].tutorialState == 11) {
		[self popup:@"Not only can you launch attacks, but you can also sabotage the opponent's scope.  Inverted Scope sabotage reverses your opponent's scope controls.  If this happens to you, defeat 3 Agents to remove it from your scope.  Click the 2nd button from the bottom (scope icon) and choose the -X -Y scope icon.  Recon indicates that you launched Invert Scope. Then try to move." t:@"Wrist Computer - Inverted Scope"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T2;
		[[[AppDelegate get].m1.childButtons objectAtIndex:0] disable];
		[[[AppDelegate get].m2.childButtons objectAtIndex:1] enable];
		successCount = 0;
		targetCount = 1;
		}
	}
	else if ([AppDelegate get].tutorialState == 12) {
		invertKills = 0;
		[self popup:@"I mentioned Recon shows the attacks you launch.  You can also see what your opponent launches by enabling Recon.  Your attacks are green, the opponent's are red.  Click the 3rd button from the bottom (walkie talkie) and choose the walkie talkie icon.  Recon will indicate that you have Recon Enabled.  We will simulate the opponent launching a paratrooper.  It will show Paratrooper in red." t:@"Wrist Computer - Recon"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T3;
		[[[AppDelegate get].m2.childButtons objectAtIndex:1] disable];
		[[[AppDelegate get].m3.childButtons objectAtIndex:0] enable];
		successCount = 0;
		targetCount = 1;
		}
	}
	else if ([AppDelegate get].tutorialState == 13) {
		[self popup:@"You can sabotage your oppoent's Recon to prevent them from seeing Recon messages as well.  When this happens to you, look in the main building for 3 radios on random floors.  You must shoot them all to get your Recon back to normal.  Click the 3rd button from the bottom (walkie talkie) and choose the Anti walkie talkie icon.  Then shoot the radios." t:@"Wrist Computer - Anti Recon"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T3;
		[[[AppDelegate get].m3.childButtons objectAtIndex:0] disable];
		[[[AppDelegate get].m3.childButtons objectAtIndex:1] enable];
		successCount = 0;
		targetCount = 2;
		}
	}	
	else if ([AppDelegate get].tutorialState == 14) {
		[self removeChildByTag:555 cleanup:YES];
		[self popup:@"Helicopters and Trucks carry two troops each and have a driver or pilot.  They will pick up and drop off two troops forever.  The only way to stop them is to shoot the driver/pilot.  Launch a helicopter and then try to shoot the pilot.  It will show up above the left building just for training.  Click the 2nd button from the top (helicopter) and choose the helicopter icon." t:@"Wrist Computer - Shoot Pilot"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T4;
		[[[AppDelegate get].m3.childButtons objectAtIndex:1] disable];
		[[[AppDelegate get].m4.childButtons objectAtIndex:2] enable];
		successCount = 0;
		targetCount = 1;
		}
	}	
	else if ([AppDelegate get].tutorialState == 15) {
		[self removeChildByTag:555 cleanup:YES];
		[self popup:@"The top row has special ONE USE abilities. Whoever gets an ability first during a match is the only person able to use it for the entire match.  Body Guards will put a body guard on each side of Smitty.  They can fight off 2 Agents each." t:@"Wrist Computer - Special Abilities"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T5;
		[[[AppDelegate get].m4.childButtons objectAtIndex:2] disable];
		successCount = 0;
		targetCount = 0;
		}
	}
	else if ([AppDelegate get].tutorialState == 16) {
		self.position = ccp(-pres.position.x,pres.position.y);
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showArmageddon];
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showMachinegun];
		[self sendMyIntel:@"Armageddon Ready"];
		[self sendMyIntel:@"Machinegun Ready"];
		[self popup:@"When you choose Armageddon or Machine Gun, the action is not instant but it is reserved for you.  You will get an icon above the FIRE button.  Armageddon will destroy everything on both screens.  You will lose all of your money but your opponent will keep their money.  Machine gun provides a machine gun with plenty of ammo to mow down enemies." t:@"Wrist Computer - Special Abilities"];
		if (lastState != [AppDelegate get].tutorialState) {
		[AppDelegate get].money=T5;
		successCount = 0;
		targetCount = 0;
		}
	}
	else if ([AppDelegate get].tutorialState == 17) {
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] hideArmageddon];
		[(ControlLayer*) [self.parent getChildByTag:kControlLayer] hideMachinegun];
		[self popup:@"Last step!  In multiplayer, your goal is to get your Agents to their leader while protecting your own leader - Smitty.  When your Agents get there, they will sound an alarm and unveil the location of your sniper opponent.  Your last task is to shoot the sniper in the right building.  Follow the blue arrow and shoot your opponent to win.  Your opponent has the same goal, so be quick.  " t:@"End Game"];
		if (lastState != [AppDelegate get].tutorialState) {
			[AppDelegate get].money=0;
			successCount = 0;
			targetCount = 1;
			//[self launchSniperFound];
		}
	}
	else if ([AppDelegate get].tutorialState == 18) {
		if (lastState != [AppDelegate get].tutorialState) {
		[self kill];
		[AppDelegate get].kidnappers = 0;
		CCLOG(@"tut:%i, max:%i",[AppDelegate get].stats.tut,MAXTUT);
		if ([AppDelegate get].stats.tut == 0) {
			[AppDelegate get].stats.tut = 1;
			[[AppDelegate get] writeData:@"t" d:[AppDelegate get].stats];
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"t"] != nil) {
				int t = [[NSUserDefaults standardUserDefaults] integerForKey:@"t"];
				[AppDelegate get].loadout.g += t * 400;
				
			}
			else {
				[AppDelegate get].loadout.g += 800;
			}
			[[AppDelegate get] writeData:@"l" d:[AppDelegate get].loadout];
			[AppDelegate showNotification:@"Achievement Earned: Due Diligence"];
			[[AppDelegate get].gkHelper reportAchievementWithID:@"osl6" percentComplete:100.0f];
			[self popup:@"Congratulations - you completed training!  Your gold has been updated.  You can use it in the Customize Section or in Multiplayer Wager Matches.  I suggest you play Sandbox Mode to try all the attacks as well as test your upgrades you purchase with gold.  Good Luck.  I anticipate you will be the Top Mercenary on the leaderboards." t:@"Training Complete"];
		}
		else {
			[self popup:@"Congratulations - you completed training again!  Good Luck.  I anticipate you will be the Top Mercenary on the leaderboards." t:@"Training Complete"];
		}
		successCount = 0;
		targetCount = 0;
		}
	}
	else if ([AppDelegate get].tutorialState == 19) {
		[[CCDirector sharedDirector] replaceScene:[MenuScene node]];
	}
	lastState = [AppDelegate get].tutorialState;
}

-(void)launchAnti {
	CCLOG(@"launchAnti");
	[AppDelegate get].jammers = 0;
	if (![[AppDelegate get] perkEnabled:11]) {
		[self sendIntel:@"Anti Recon"];
		[self sendIntel:@"U got Roll'd"];
		[self sendIntel:@"Shoot jammers"];

		Radio *radio = [[Radio alloc] initWithFile: @"jammer.png" l:self];
		radio.position=ccp(pres.position.x+40,FLOOR4Y);
		
		CCSprite *pointer = [CCSprite spriteWithFile:@"arrow1.png"];
		pointer.position=ccp(radio.position.x-radio.contentSize.width/2-20,radio.position.y);
		pointer.scale=0.3;
		[self addChild:pointer z:radio.zOrder tag:555];
		
		[radio release];
		//CGPoint d = ccpSub([radio convertToWorldSpace:ccp(0.5,0.5)],[self convertToWorldSpace:ccp(0.5,0.5)]);
		//[self moveBGPostion:d.x y:d.y];
		self.position = ccp(-pres.position.x,pres.position.y);
		if ([AppDelegate get].anti == 0)
			jammerID = [[AppDelegate get].soundEngine playSound:7 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:YES];
		
	}
}

-(void) pauseKill {
	Enemy *e = (Enemy*) [self getChildByTag:12345];
	[e kill];
}

-(void) menuAttack:(int)attack {
	switch (attack)
    {
        case CODEAGENT: // Agent
			if ([AppDelegate get].tutorialState == 10) {
				[AppDelegate get].money=0;
				[self sendMyIntel:@"Agent"];
				Enemy *enemy = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];	 
				enemy.color = ccRED;
				enemy.tag = 12345;
				//enemy.position = ccp(1200,SIDEWALK);
				[enemy startMoving:ccp(1200,SIDEWALK)];
				self.position = ccp(-700,-enemy.position.y);
				successCount++;
				[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
				//[self showSuccess];
				[self schedule: @selector(pauseKill) interval: 1.5];
				[self schedule: @selector(pauseSuccess) interval: 3];
			}
	break;
	case CODEINVERTED: // Inverted Scope
			if ([AppDelegate get].tutorialState == 11) {
				successCount++;
				[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
				[AppDelegate get].money=0;
				[self sendMyIntel:@"Inverted Scope"];
				[self launchInverted];
				[self schedule: @selector(pauseSuccess) interval: 5];
			}
		break;
	case CODETHUMB: // Dirty Scope
			if ([AppDelegate get].tutorialState == 11) {
				successCount++;
				[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
				[self sendMyIntel:@"Scope Smudge"];
				[AppDelegate get].money=0;
				[self launchDirt];
				[self schedule: @selector(pauseSuccess) interval: 5];
			}
		break;
	case CODERECON: // Recon
		if ([AppDelegate get].tutorialState == 12) {
			successCount++;
			[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			[AppDelegate get].money=0;
			[self sendMyIntel:@"Recon Enabled"];
			[self launchRecon];
			[self sendIntel:@"Paratrooper"];
			[self showSuccess];
		}
		break;
	case CODEANTI: // Anti-Recon
		if ([AppDelegate get].tutorialState == 13 && successCount == 0) {
			//[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			successCount++;
			//[AppDelegate get].money=0;
			[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideArrow];
			[self launchAnti];
		}
		break;
	case CODECHOPPER: // Helicopter
		if ([AppDelegate get].tutorialState == 14) {
			[AppDelegate get].money-=T4;
			successCount++;
			[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideArrow];
			//[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			Helicopter *vehicle = [[Helicopter alloc] initWithFile: @"chopper1.png" l:self a:[AppDelegate get].heliStartPoint];
			[self addChild:vehicle z:8];
			[vehicle addPassengers];
			vehicle.position = ccp(pres.position.x,SKYY);
			[vehicles addObject:vehicle];
			
			CCSprite *pointer = [CCSprite spriteWithFile:@"arrow1.png"];
			pointer.position=ccp(vehicle.position.x-vehicle.contentSize.width/2+30,vehicle.position.y);
			pointer.scale=0.3;
			[self addChild:pointer z:vehicle.zOrder tag:555];
			
			//[vehicles addObject:vehicle];
			//[vehicle startMoving:ccp(0,0)];
			[self sendMyIntel:@"Helicopter"];
			self.position = ccp(-pres.position.x,pres.position.y-240);
		}
		break;
	case CODEPERK2: // MachineGun
			if ([AppDelegate get].tutorialState == 17) {
			[AppDelegate get].money-=T5;
			[(ControlLayer*) [self.parent getChildByTag:kControlLayer] showMachinegun];
			[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			[self launchMachinegun];
		}
		break;
	case KIDNAPPERDEAD: // Kidnapper Dead
		[self sendMyIntel:@"Interrogator Dead"];
		[self launchKidnapperDead];
		break;
	case SNIPERFOUND: // Sniper Found
		[self sendMyIntel:@"Sniper Located"];
		[self launchSniperFound];
		break;
	case CODELOSE: // You Win
		if ([AppDelegate get].tutorialState == 17) {
			successCount++;
			[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			[self showSuccess];
		}			
		break;	
	}
}

-(void) showSuccess {
	//successCount++;
	[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] showSuccess];
	[[AppDelegate get].soundEngine playSound:20 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN-0.2 loop:NO];
	if (successCount >= targetCount) {
		[AppDelegate get].tutorialState++;
		[self schedule: @selector(pauseStep) interval: 2];
	}
}

-(void) pauseStep {
	[self unschedule:@selector(pauseStep)];
	[self nextStep];
}

-(void) pauseSuccess {
	CCLOG(@"PauseSuccess");
	[self unschedule:@selector(pauseSuccess)];
	successCount++;
	[self showSuccess];
}

-(void) popup: (NSString*) m t:(NSString*)t {
	[[[CCDirector sharedDirector] runningScene] popup:m t:t];
}

-(void) popupClicked {
	CCLOG(@"PopupClicked tutorialState:%i",[AppDelegate get].tutorialState);	
	if (successCount >= targetCount) {
		[AppDelegate get].tutorialState++;
		[self nextStep];
	}
	else {
		[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] showQuestion];
	}
}

-(void) pressedArmageddon {
	[super pressedArmageddon];
	successCount++;
	[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
	[self schedule: @selector(pauseSuccess) interval: 5];	
}

-(void) fireMachinegun {
	if (machinegunCount == 300)
		[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
	machinegunCount--;
	[[AppDelegate get].soundEngine playSound:2 sourceGroupId:0 pitch:1.0f pan:0.0f gain:DEFGAIN loop:NO];
	[self shotFired];
	if (machinegunCount < 0) {
		[self unschedule: @selector(fireMachinegun)];
		[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] showScope];
		[self schedule: @selector(checkIfSighted) interval: 0.1];
		successCount++;
		[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
		[self showSuccess];
		[self kill];
	}
}

-(void)towTruck: (Vehicle*) v {
	for (Vehicle *v in vehicles) {
		[v kill];
	}
	[self kill];
	[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
	successCount++;
	[self showSuccess];
}

-(void) kill 
{
	for (Vehicle *v in vehicles) {
		[v kill];
	}
	for (Enemy *e in [AppDelegate get].enemies) {
		if (e.type != 100)
			[e kill];
	}
}

- (void) setZoom:(float) z {
	[super setZoom:z];
	if ([AppDelegate get].tutorialState == 6) {
		successCount++;
		if (successCount >= targetCount) {
			[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			[self showSuccess];
		}
	}
}

- (void) setZoom2:(float) z {
	CGPoint orig = self.position;
	float xDiff,yDiff;
	xDiff = self.position.x - 0;
	yDiff = self.position.y - 0;
	//CCLOG(@"diff x:%f y:%f",xDiff,yDiff);
	if (z == [AppDelegate get].maxZoom) {
		//CCLOG(@"diff scale x:%f y:%f",xDiff*0.5f,yDiff*0.5f);
		orig.x += xDiff;
		orig.y += yDiff;
	}
	else {
		orig.x -= xDiff*z;
		orig.y -= yDiff*z;
	}
	[AppDelegate get].scale = z;
	self.scale = z;
	self.position = ccp(orig.x,orig.y);
}

- (int) shotFired {
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	CCLOG(@"shot position: %f,%f",[[UIScreen mainScreen] bounds].size.height/2-location.x,160-location.y);
	int gotHim = -1;
	int headshot = 0;
	CCLOG(@"enemies count %i",[[AppDelegate get].enemies count]);
	for (int i = 0; i < (int) [[AppDelegate get].enemies count]; i++) {
		Enemy *enemy = [[AppDelegate get].enemies objectAtIndex:i];
		int wasShot = [enemy checkIfShot];
		CCLOG(@"wasShot=%i",wasShot);
		if (wasShot > 0) {
			if (enemy.customTag == 99)
				[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
			if ([AppDelegate get].tutorialState == 13 || [AppDelegate get].tutorialState == 14) {
				successCount++;
				if (successCount == targetCount) {
					[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
					[self showSuccess];
				}
			}
			if (wasShot == 2) {
				if ([AppDelegate get].tutorialState == 5) {
					headshot=1;
					[AppDelegate get].headshotStreak++;
					//[self doHeadshot:enemy.position i:wasShot];
					successCount++;
					if (successCount == targetCount) {
						[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
						[self showSuccess];
					}
				}
				else if ([AppDelegate get].tutorialState == 7) {
					successCount=0;
					[three setString:@"3x"];
					[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
					Enemy *enemy2 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];	 
					enemy2.color = ccRED;
					enemy2.position = ccp(BUILDING2LEFT+100,ROOF);
					[self popup:@"You were supposed to shoot the Agent in the body 3 times.  Please try again." t:@"Failed"];
				}
			}
			else {
				if ([AppDelegate get].tutorialState == 7) {
					successCount++;
					CCLOG(@"bodyshot tutorialState:%i",[AppDelegate get].tutorialState);
					CCLOG(@"bodyshot successCount:%i",successCount);
					if (successCount == targetCount) {
						[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
						[self showSuccess];
					}
				}
				else if ([AppDelegate get].tutorialState == 5) {
					successCount=0;
					[(TutorialControlLayer*) [self.parent getChildByTag:kControlLayer] hideQuestion];
					Enemy *enemy2 = [[Enemy alloc] initWithFile: @"walk1.png" l:self h:@"hat1.png"];	 
					enemy2.color = ccRED;
					enemy2.position = ccp(BUILDING2LEFT+100,ROOF);
					[self popup:@"You were supposed to shoot the Agent in the head.  Please try again." t:@"Failed"];
				}
			}
			gotHim = i;
			if (dirtKills > 0) {
				dirtKills--;
				if (dirtKills == 0)
					[(ScopeLayer*) [self.parent getChildByTag:kScopeLayer] blurryOff];
				
			}
			if (invertKills > 0)
				invertKills--;
			break;
		}
		if ([AppDelegate get].tutorialState == 7) {
			[three setString:[NSString stringWithFormat: @"%ix", 3-enemy.hits]];
		}
	}
	CCLOG(@"heashot=%i",headshot);
	if (headshot == 0)
		[AppDelegate get].headshotStreak=0;
	
	if (gotHim > -1) {
		[[AppDelegate get].enemies removeObjectAtIndex:gotHim];
		return [[AppDelegate get].enemies count];
	}
	else {
		[AppDelegate get].headshotStreak=0;
		return gotHim;
	}
}

- (void) dealloc {
	//[[CCTextureMgr sharedTextureMgr] removeUnusedTextures];
	CCLOG(@"dealloc TutorialLayer"); 
	[super dealloc];
}

@end

@implementation TutorialControlLayer
- (id) init {
	CCLOG(@"ControlLayer");
    self = [super init];
    if (self != nil) {	
		CGSize s = [[CCDirector sharedDirector] winSize];
		success = [CCSprite spriteWithFile:@"checkmark.png"];
		success.position = ccp(s.width/2,s.height-60);
		success.visible = FALSE;
		[self addChild:success z:100];
		JDMenuItem *q = [JDMenuItem itemFromNormalImage:@"questionmark.png" selectedImage:@"questionmark.png" 
													 target:self
												   selector:@selector(question:)];
		
		questionMenu = [CCMenu menuWithItems:q, nil];
		[questionMenu alignItemsVerticallyWithPadding: 10.0f];
		questionMenu.position = ccp(s.width/2,s.height-16);
		[self addChild:questionMenu z:100];
		[self hideQuestion];
		[self disableAll];
		[self schedule: @selector(doReload) interval: .6];
		arrow = [CCSprite spriteWithFile:@"arrow1.png"];
		arrow.position=ccp([[UIScreen mainScreen] bounds].size.height/2,160);
		[self addChild:arrow z:4];
		arrow.visible=FALSE;
	}
	return self;
}

-(void) popup: (NSString*) m t:(NSString*)t {
	CCLOG(@"popup");
	CCLayer *popup = [[[PopupLayer alloc] initWithMessage:m t:t] autorelease];
	[self addChild:popup z:10];
	arrow.visible = FALSE;
}

-(void) hideQuestion {
	questionMenu.position = ccp(-10000,-10000);
	arrow.visible=FALSE;
}

-(void) showQuestion {
	CGSize s = [[CCDirector sharedDirector] winSize];
	questionMenu.position = ccp(s.width/2,s.height-16);
	arrow.visible=FALSE;
	arrow.scale = 1;
	if ([AppDelegate get].tutorialState == 5 || [AppDelegate get].tutorialState == 7) {
		//Rotate arrow
		CGPoint location = [(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] convertToWorldSpace:ccp(0.5,0.5)];
		Enemy *e = [[AppDelegate get].enemies objectAtIndex:1];
		CGPoint sniperPosition = [e convertToWorldSpace:ccp(0.5,0.5)];
		CCLOG(@"layerpos:%f,%f sniper:%f,%f",location.x,location.y,sniperPosition.x,sniperPosition.y);
		arrow.position=ccp([[UIScreen mainScreen] bounds].size.height/2,160);
		arrow.rotation = 360-(findAngle(sniperPosition,ccp(100-(location.x/[AppDelegate get].scale),160-(location.y/[AppDelegate get].scale))));
		arrow.visible = TRUE;
		[self schedule: @selector(doArrow) interval: 1];
	}
	else if ([AppDelegate get].tutorialState == 6) {
		arrow.scale = 0.8;
		arrow.rotation=120;
		arrow.position=ccp(zoomedInButton.position.x+40,zoomedInButton.position.y+80);
		arrow.visible = TRUE;
	}
	else if ([AppDelegate get].tutorialState == 10) {
		arrow.scale = 0.8;
		arrow.rotation=180;
		arrow.position=ccp(menuTray.position.x+80,[AppDelegate get].m1.position.y);
		arrow.visible = TRUE;
	}
	else if ([AppDelegate get].tutorialState == 11) {
		arrow.scale = 0.8;
		arrow.rotation=180;
		arrow.position=ccp(menuTray.position.x+80,[AppDelegate get].m2.position.y);
		arrow.visible = TRUE;
	}
	else if ([AppDelegate get].tutorialState == 12 || [AppDelegate get].tutorialState == 13) {
		arrow.scale = 0.8;
		arrow.rotation=180;
		arrow.position=ccp(menuTray.position.x+80,[AppDelegate get].m3.position.y);
		arrow.visible = TRUE;
	}
	else if ([AppDelegate get].tutorialState == 14) {
		arrow.scale = 0.8;
		arrow.rotation=180;
		arrow.position=ccp(menuTray.position.x+80,[AppDelegate get].m4.position.y);
		arrow.visible = TRUE;
	}
	else if ([AppDelegate get].tutorialState == 15) {
		arrow.scale = 0.8;
		arrow.rotation=180;
		arrow.position=ccp(menuTray.position.x+80,[AppDelegate get].m5.position.y);
		arrow.visible = TRUE;
	}
	else if ([AppDelegate get].tutorialState == 17) {
		arrow.visible = FALSE;
		[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] launchSniperFound];
	}
	
	else {
		arrow.visible=FALSE;
	}
	
}

-(void) question: (id)sender {
	[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] nextStep];	
}
-(void) hideArrow {
	arrow.visible=FALSE;
}

-(void) showSuccess {
	//successCount++;
	success.visible=YES;
	[success runAction: [CCFadeOut actionWithDuration:1]];
}

-(void) fireButtonPressed: (id)sender {
	CCLOG(@"Fire Button Pressed");
	if ([AppDelegate get].reload == 0) {
		[[AppDelegate get].soundEngine playSound:0 sourceGroupId:0 pitch:0.6f pan:0.0f gain:DEFGAIN loop:NO];
		[(BackgroundLayer*) [self.parent getChildByTag:kBackgroundLayer] shotFired];
		
		[AppDelegate get].reload = 1;
		[self schedule: @selector(doReloadSound) interval: .2];
		

		[self schedule: @selector(doReload) interval: .6];

	}
	
}

-(void) showPerks {
	
}

-(void) moneyProgress {
	[self unschedule:@selector(moneyProgress)];
}

- (void) disableAll
{
	[[[AppDelegate get].m1.childButtons objectAtIndex:0] disable];
	[[[AppDelegate get].m1.childButtons objectAtIndex:1] disable];
	[[[AppDelegate get].m1.childButtons objectAtIndex:2] disable];
	[[[AppDelegate get].m2.childButtons objectAtIndex:0] disable];
	[[[AppDelegate get].m2.childButtons objectAtIndex:1] disable];
	[[[AppDelegate get].m2.childButtons objectAtIndex:2] disable];
	[[[AppDelegate get].m3.childButtons objectAtIndex:0] disable];
	[[[AppDelegate get].m3.childButtons objectAtIndex:1] disable];
	[[[AppDelegate get].m3.childButtons objectAtIndex:2] disable];
	[[[AppDelegate get].m4.childButtons objectAtIndex:0] disable];
	[[[AppDelegate get].m4.childButtons objectAtIndex:1] disable];
	[[[AppDelegate get].m4.childButtons objectAtIndex:2] disable];
	[[[AppDelegate get].m5.childButtons objectAtIndex:0] disable];
	[[[AppDelegate get].m5.childButtons objectAtIndex:1] disable];
	[[[AppDelegate get].m5.childButtons objectAtIndex:2] disable];
}

float findAngle(CGPoint pt1, CGPoint pt2) {
	float angle = atan2(pt1.y - pt2.y, pt1.x - pt2.x) * (180 / M_PI);
	angle = angle < 0 ? angle + 360 : angle;
	
	return angle;
}

- (void) doArrow {
	arrow.visible=FALSE;
	[self unschedule:@selector(doArrow)];
}
@end


