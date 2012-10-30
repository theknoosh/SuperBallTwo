//
//  Launcher.h
//  SuperBallTwo
//
//  Created by DPayne on 8/31/12.
//
//

#import "GB2Sprite.h"

@class GameLayer;

@interface Launcher : GB2Sprite
{
    GameLayer *gameLayer; // weak reference
    ccTime  animDelay; // control speed of animation
    int     animPhase;        // the current animation phase
    bool    openLauncher;
    
}

-(id) initWithGameLayer:(GameLayer*)gl;
-(void)setToOpen;


@end
