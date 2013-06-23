//
//  Ball.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define JUMP_IMPULSE 2.0f

#import "Ball.h"
#import "GameLayer.h"
#import "GB2Contact.h"

#define ANIM_SPEED .05f


@implementation Ball

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithDynamicBody:@"SteamBot"
                      spriteFrameName:@"SteamBot.png"];
    
    if(self)
    {
        
        [self setBullet:YES];
        [self setFixedRotation:true];
        
        gameLayer = gl;
        _inContact = false;
        animPhase = 0;
        
        // (arc4random() % (max-min+1)) + min
        blinkDelay = (arc4random() % (10-1+1)) + 1;
        blinkOpen = true;
        
        animDelay = ANIM_SPEED;
        
        botMood = @"Normal";
        botAnim = @"Blink";
    }
    return self;
}


-(void) beginContactWithPiston:(GB2Contact*)contact
{
    NSString *fixtureID = (NSString *)contact.otherFixture->GetUserData();
    NSLog(@"Fixture ID = %@", fixtureID);
    
}

-(void)beginContactWithStaticObject:(GB2Contact*)contact
{
    NSString *fixtureID = (NSString *)contact.otherFixture->GetUserData();
    
    // get balls position
    b2Vec2 pos = [self physicsPosition];
    
    // Convert from b2Vec2 to CGPoint
    CGPoint posConv = ccpMult(CGPointMake(pos.x, pos.y), PTM_RATIO);    
    
    NSLog(@"Fixture ID = %@ at position %f,%f", fixtureID, posConv.x,posConv.y);
    
    // [self applyLinearImpulse:b2Vec2(-([self mass]*JUMP_IMPULSE),[self mass]*JUMP_IMPULSE) point:[self worldCenter]];
    _inContact = true;
}

// This is needed for character animation

-(void) updateCCFromPhysics {
    
    [super updateCCFromPhysics];
    
    NSString    *frameName;
    
    if (blinkDelay > 0) {
        blinkDelay -= 1.0f/30.0f;
    }

    if (blinkDelay <= 0) {
        blinkNow = true;
    }
    
    if (blinkNow) {
        
        animDelay -= 1.0f/30.0f;
    
        if(animDelay <= 0)
        {
            animDelay = ANIM_SPEED;
        
            if (blinkOpen) {
                animPhase++;
                botHasChanged = true;
                if(animPhase > 3)
                {
                    animPhase = 3;
                    blinkOpen = false;
                }
            }else {
                animPhase--;
                botHasChanged = true;
                if (animPhase<0) {
                    animPhase = 0;
                    
                    //  Blinking sequence is finished, reset
                    blinkNow = false;
                    blinkOpen = true;       
                    blinkDelay = (arc4random() % (10-1+1)) + 1;
                }
            }
        } 
    }
    
    if (botHasChanged) {
        
        frameName = [NSString stringWithFormat:@"SteamBot%@%@0%d.png",botMood,
                 botAnim,animPhase];

        [self setDisplayFrameNamed:frameName];
        botHasChanged = false;
    }
    
}

-(void)setMood:(int)Mood{
    switch (Mood) {
        case 0:
            botMood = @"Normal";
            break;
        case 1:
            botMood = @"Angry";
            break;
            
        default:
            botMood = @"Normal";
            break;
    }
}


@end
