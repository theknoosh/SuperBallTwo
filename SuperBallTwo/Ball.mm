//
//  Ball.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define JUMP_IMPULSE 5.0f

#import "Ball.h"
#import "GameLayer.h"
#import "GB2Contact.h"


@implementation Ball

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithDynamicBody:@"Ball"
                      spriteFrameName:@"Ball.png"];
    
    if(self)
    {
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        [self setFixedRotation:FALSE];
        
        gameLayer = gl;
        _inContact = false;
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
    
    [self applyLinearImpulse:b2Vec2(0,[self mass]*JUMP_IMPULSE) point:[self worldCenter]];
    _inContact = true;
}

/* -(void) endContactWithPiston:(GB2Contact*)contact
{
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    if([fixtureId isEqualToString:@"ContactLeft"])
    {
        numContactLeftContacts--;
    }
    else if([fixtureId isEqualToString:@"ContactRight"])
    {
        numContactRightContacts--;
    }
    else if([fixtureId isEqualToString:@"ContactTop"])
    {
        numContactTopContacts--;
    }
    else
    {
        // count others as floor contacts
        numContactBottomContacts--;
    }
    
}*/

@end
