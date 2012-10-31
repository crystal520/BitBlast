//
//  Debug.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/27/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#ifndef GunRunner_Debug_h
#define GunRunner_Debug_h

// if enabled, all SFX will be muted
#define DEBUG_NO_SOUND 1
// if enabled, all music will be muted
#define DEBUG_NO_MUSIC 1
// if enabled, all phsyics objects will draw their debug info
#define DEBUG_PHYSICS 0

// PLAYER VARIABLES
// if enabled, player will never lose health
#define DEBUG_GOD_MODE 0
// number of keys to start the player out with (out of 7)
#define DEBUG_OVERRIDE_KEYS 0
// number of triforces to start the player out with (out of 4)
#define DEBUG_OVERRIDE_TRIFORCE 0

// ENVIRONMENT VARIABLES
// if enabled, promo will always display
#define DEBUG_ALWAYS_SHOW_PROMO 0
// if enabled, player's saved data will be reset
#define DEBUG_RESET_SAVED_DATA 0
// if enabled, player will start every run with the tutorial
#define DEBUG_ENABLE_TUTORIAL 0
// if enabled, will show fps, as well as some other stats
#define DEBUG_SHOW_FPS 0
// if enabled, will allow testing data to be associated with a tester's device
#define DEBUG_TEST_FLIGHT_DEVICE 1

// ENEMY VARIABLES
// if enabled, boss will be spawned at the start of every run
#define DEBUG_SPAWN_BOSS 0
// override the amount of health a miniboss has
#define DEBUG_OVERRIDE_MINIBOSS_HEALTH 0
// override the amount of health the boss has
#define DEBUG_OVERRIDE_BOSS_HEALTH 0

// WEAPON VARIABLES
// if enabled, will automatically give player all guns
#define DEBUG_ALL_GUNS 0
// if enabled, will reset the player to only have the pistol unlocked
#define DEBUG_PISTOL_ONLY 0

#endif
