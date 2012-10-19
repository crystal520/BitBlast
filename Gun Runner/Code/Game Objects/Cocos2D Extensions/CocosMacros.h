//
//  CocosMacros.h
//  Gun Runner
//
//  Created by Kristian Bauer on 10/18/12.
//
//

#ifndef Gun_Runner_CocosIncludes_h
#define Gun_Runner_CocosIncludes_h

/** @def CCRANDOM_MIN_MAX
 returns a random float between min and max
 */
#define CCRANDOM_MIN_MAX(__MIN__, __MAX__) (__MIN__ + (CCRANDOM_0_1() * (__MAX__ - __MIN__)))

#endif
