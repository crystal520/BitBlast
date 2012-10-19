//
//  SimpleAudioEngine+Extended.m
//  Gun Runner
//
//  Created by Kristian Bauer on 10/17/12.
//
//

#import "SimpleAudioEngine+Extended.h"

@implementation SimpleAudioEngine (Extended)

- (BOOL) isBackgroundMusicPlaying:(NSString*)file {
    return [[CDAudioManager sharedManager].backgroundMusic.audioSourceFilePath isEqualToString:file];
}

@end
