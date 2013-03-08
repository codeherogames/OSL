//
//  GameConfig.h
//  PixelSniper
//
//  Created by James Dailey on 1/20/11.
//  Copyright James Dailey 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationUIViewController
//#define GAME_AUTOROTATION kGameAutorotationCCDirector if GC won't work

#endif // __GAME_CONFIG_H