//
//  SettingsManager.m
//

#import "SettingsManager.h"

@implementation SettingsManager

static SettingsManager* _sharedSettingsManager = nil;

-(NSString *) getString:(NSString*)keyString
{
	return [settings objectForKey:keyString];
}

-(int) getInt:(NSString*)keyString {
	return [[settings objectForKey:keyString] intValue];
}

-(float) getFloat:(NSString*)keyString {
	return [[settings objectForKey:keyString] floatValue];
}

-(double) getDouble:(NSString*)keyString {
	return [[settings objectForKey:keyString] doubleValue];
}

-(bool) getBool:(NSString*)keyString {
	return [[settings objectForKey:keyString] boolValue];
}

-(CGPoint) getCGPoint:(NSString*)keyString {
	return [[settings objectForKey:keyString] CGPointValue];
}

- (BOOL) doesExist:(NSString *)keyString {
    return ([settings objectForKey:keyString] != nil);
}

- (void) clear:(NSString *)keyString {
    [settings removeObjectForKey:keyString];
}

- (void) clearWeapons {
    [self setBool:NO keyString:@"highenergyshot"];
    [self setBool:NO keyString:@"ultraLaser"];
    [self setBool:NO keyString:@"wavegun"];
    [self setBool:NO keyString:@"flamethrower"];
    [self setBool:NO keyString:@"ripley"];
    [self setBool:NO keyString:@"bluewave"];
    [self setBool:NO keyString:@"spreadgun"];
    [self setBool:NO keyString:@"shotgun"];
    [self setBool:NO keyString:@"supershotgun"];
    [self setBool:NO keyString:@"gattlingun"];
    [self setBool:NO keyString:@"machinegun"];
    [self setBool:NO keyString:@"burstshot"];
    [self setBool:NO keyString:@"plasmapistol"];
    [self setBool:NO keyString:@"experimentalplasmapistol"];
}

- (void) awardMedal {
    // get medals as an array
    NSMutableArray *medals = [NSMutableArray arrayWithArray:[[self getString:@"medals"] componentsSeparatedByString:@","]];
    // get random medal to unlock
    int ran = MIN(CCRANDOM_MIN_MAX(0, [medals count]), [medals count]-1);
    int medalToUnlock = [[medals objectAtIndex:ran] intValue];
    // remove medal from medals string so we don't unlock it twice
    [medals removeObjectAtIndex:ran];
    // reconstruct medals string using the rest of the medals in the array
    NSMutableString *medalsString = [NSMutableString stringWithString:@""];
    for(NSString *s in medals) {
        [medalsString appendFormat:@"%@,", s];
    }
    [medalsString setString:[medalsString substringToIndex:[medalsString length]-1]];
    // save medal
    if([self doesExist:@"unlockedMedals"]) {
        [self setString:[NSString stringWithFormat:@"%@,%i", [self getString:@"unlockedMedals"], medalToUnlock] keyString:@"unlockedMedals"];
    }
    else {
        [self setString:[NSString stringWithFormat:@"%i", medalToUnlock] keyString:@"unlockedMedals"];
    }
    // also save to most recently unlocked
    [self setInteger:medalToUnlock keyString:@"newMedal"];
}

- (BOOL) hasMedalsLeft {
    return (![[self getString:@"medals"] isEqualToString:@""]);
}

-(void) setString:(NSString*)value keyString:(NSString *)keyString {
	[settings setObject:value forKey:keyString];
}

-(void) setInteger:(int)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%i",value] forKey:keyString];
}

-(void) setFloat:(float)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%f",value] forKey:keyString];
}

-(void) setDouble:(double)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%f",value] forKey:keyString];
}

-(void) setCGPoint:(CGPoint)value keyString:(NSString*)keyString {
	[settings setObject:[NSValue valueWithCGPoint:value] forKey:keyString];
}

-(void) setBool:(bool)value keyString:(NSString*)keyString {
	[settings setObject:[NSString stringWithFormat:@"%i",value] forKey:keyString];
}

- (void) incrementInteger:(int)value keyString:(NSString*)keyString {
	// get value first
	int val = [self getInt:keyString];
	// add increment
	val += value;
	// re-save back
	[self setInteger:val keyString:keyString];
}

-(void) saveToNSUserDefaults:(NSString*)appName
{
	[[NSUserDefaults standardUserDefaults] setObject:settings forKey:appName];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) loadFromNSUserDefaults:(NSString*)appName;
{
	[self purgeSettings];
	[settings addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:appName]];
}

-(void) saveToFile:(NSString*) fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *plistDirectory = [paths objectAtIndex:0];
	NSString *fullPath = [plistDirectory stringByAppendingPathComponent:fileName];
	
	bool writeSuccess = [settings writeToFile:fullPath atomically:YES];
	
	if(!writeSuccess)
	{
		CCLOG(@"Couldn't write settings file");
	}
	else
	{
		CCLOG(@"Write success to settings file");
	}
}

-(void) loadFromFile:(NSString*) fileName
{
	// Clear first
	[self purgeSettings];
	[settings release];
	
	// read it back in with different dictionary variable
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *plistDirectory = [paths objectAtIndex:0];
	NSString *fullPath = [plistDirectory stringByAppendingPathComponent:fileName];
	
	settings = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
	
	if (settings != nil)
	{
		CCLOG(@"settings read success");
	}
	else
	{
		CCLOG(@"settings read failure");
		settings = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
	}
    
#if DEBUG_OVERRIDE_KEYS
    [self setInteger:DEBUG_OVERRIDE_KEYS keyString:@"totalKeys"];
#endif
#if DEBUG_OVERRIDE_TRIFORCE
    [self setInteger:DEBUG_OVERRIDE_TRIFORCE keyString:@"totalTriforce"];
#endif
#if DEBUG_ALL_GUNS
    [self setBool:YES keyString:@"highenergyshot"];
    [self setBool:YES keyString:@"ultraLaser"];
    [self setBool:YES keyString:@"wavegun"];
    [self setBool:YES keyString:@"flamethrower"];
    [self setBool:YES keyString:@"ripley"];
    [self setBool:YES keyString:@"bluewave"];
    [self setBool:YES keyString:@"spreadgun"];
    [self setBool:YES keyString:@"shotgun"];
    [self setBool:YES keyString:@"supershotgun"];
    [self setBool:YES keyString:@"gattlingun"];
    [self setBool:YES keyString:@"machinegun"];
    [self setBool:YES keyString:@"burstshot"];
    [self setBool:YES keyString:@"plasmapistol"];
    [self setBool:YES keyString:@"experimentalplasmapistol"];
#endif
#if DEBUG_PISTOL_ONLY
    [self clearWeapons];
#endif
    
    // check to see if medals exist
    if(![self doesExist:@"medals"]) {
        [self setString:@"0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20" keyString:@"medals"];
    }
	
	[settings retain];
}

-(void) purgeSettings
{
	[settings removeAllObjects];
}

-(void) logSettings
{
	for(NSString* item in [settings allKeys])
	{
		CCLOG(@"[SettingsManager KEY:%@ - VALUE:%@]", item, [settings valueForKey:item]);
	}
}

+(SettingsManager*)sharedSingleton
{
	@synchronized([SettingsManager class])
	{
		if (!_sharedSettingsManager)
			[[self alloc] init];
		
		return _sharedSettingsManager;
	}
	
	return nil;
}

+(id) alloc
{
	@synchronized([SettingsManager class])
	{
		NSAssert(_sharedSettingsManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSettingsManager = [super alloc];
		return _sharedSettingsManager;
	}
	
	return nil;
}

-(id) autorelease {
    return self;
}

-(id) init {
	
	if (settings == nil)
	{
		settings = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	
#if DEBUG_RESET_SAVED_DATA
	[self purgeSettings];
	[self saveToFile:@"player.plist"];
	[self loadFromFile:@"player.plist"];
#endif
	
	return self;
}

@end
