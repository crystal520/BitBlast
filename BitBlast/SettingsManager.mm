//
//  SettingsManager.m
//

#import "SettingsManager.h"
#import "cocos2d.h"

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
	[settings setObject:[NSString stringWithFormat:@"%d",value] forKey:keyString];
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
	
#ifdef RESET_SAVED_DATA
	[self purgeSettings];
	[self saveToFile:@"player.plist"];
	[self loadFromFile:@"player.plist"];
#endif
	
	return self;
}

@end