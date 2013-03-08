//
//  Vector.m
//  Sniper
//
//  Created by James Dailey on 10/16/09.
//  Copyright 2009 James Dailey. All rights reserved.
//

#import "Vector.h" 
@implementation Vector 
+ (CGPoint) makeWithX: (float)x Y: (float)y 
{ 
	CGPoint vec; 
	vec.x = x; 
	vec.y = y; 
	return vec; 
} 

+ (float) distanceBetween: (CGPoint)vec1 vec2:(CGPoint)vec2 
{ 
	return sqrt(pow(vec1.x - vec2.x, 2) + pow(vec1.y - vec2.y, 2)); 
} 

+ (CGPoint) makeIdentity { return [self makeWithX: 0.0f Y: 0.0f]; } 
+ (CGPoint) add: (CGPoint) vec1 to: (CGPoint) vec2 
{ 
	vec2.x += vec1.x; 
	vec2.y += vec1.y; 
	return vec2; 
} 

// converts x y vector into angle velocity 
+ (CGPoint) asAngleVelocity:(CGPoint)vec 
{ 
	float a = atan2(vec.y, vec.x); 
	float l = [Vector length:vec]; 
	vec.x = a; 
	vec.y = l; 
	return vec; 
} 

// converts angle velocity vector into x y vector 
+ (CGPoint) fromAngleVelocity:(CGPoint)vec 
{ 
	float vel = vec.y; 
	vec.y = cos(vec.x) * vel; 
	vec.x = sin(vec.x) * vel; 
	return vec; 
} 

+ (CGPoint) truncate: (CGPoint) vec to: (float) max 
{ 
	// this is not true truncation, but is much faster 
	if (vec.x > max) vec.x = max; 
	if (vec.y > max) vec.y = max; 
	if (vec.y < -max) vec.y = -max; 
	if (vec.x < -max) vec.x = -max; 
	return vec; 
} 

+ (CGPoint) normalize:(CGPoint) pt 
{ 
	float len = [Vector length:pt]; 
	if (len == 0) return pt; 
	pt.x /= len; 
	pt.y /= len; 
	return pt; 
} 

+ (CGPoint) multiply: (CGPoint) vec by: (float) factor 
{ 
	vec.x *= factor; 
	vec.y *= factor; 
	return vec; 
} 

+ (float) lengthSquared: (CGPoint) vec 
{ 
	return (vec.x*vec.x + vec.y*vec.y); 
} 

+ (float) length: (CGPoint) vec 
{ 
	return sqrt([Vector lengthSquared: vec]); 
} 

+ (CGPoint) invert: (CGPoint) vec 
{ 
	vec.x *= -1; 
	vec.y *= -1; 
	return vec; 
} 

+ (CGPoint) subtract: (CGPoint) vec1 from: (CGPoint) vec2 
{ 
	vec2.x -= vec1.x; 
	vec2.y -= vec1.y; 
	return vec2; 
} 

@end 