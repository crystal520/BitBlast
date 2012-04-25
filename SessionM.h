//  SessionM.h
//  session M
//
//  Copyright 2011 session M. All rights reserved.
//

#ifndef __SESSIONM__
#define __SESSIONM__
#define __SESSIONM_SDK_VERSION__ @"1.1.27" // set as part of framework build
#define __SESSIONM_SDK_BUILD_REVISION__ @"a56d811c9c59a9c784287694d62b4c8a7068da92"

enum {
    SessionM_UIDisplayPortrait = 0,
    SessionM_UIDisplayLandscape = 1,
    SessionM_UIDisplayDynamic = 2
};

typedef int SessionM_UIDisplayType;


enum {
    SessionM_LogLevel_default = 0,
    SessionM_LogLevel_Info = 1,
    SessionM_LogLevel_Notice = 2,
    SessionM_LogLevel_Warn = 3,
    SessionM_LogLevel_Error = 4,
    SessionM_LogLevel_Alert = 5
};
typedef int SessionM_LogLevel;



@interface Config : NSObject {
    UIWindow *currentKeyWindow;
}

// The base url for the SessionM AP. Default is https://api.sessionm.com
@property (nonatomic,retain) NSString* ServerUrl; 

// The base url for the SessionM portal. Default is https://portal.sessionm.com
@property (nonatomic,retain) NSString* portalUrl; 

// If set to YES, it will log SDK output to the console. Default is NO. 
@property (nonatomic) BOOL LoggingEnabled;

@property (nonatomic) SessionM_LogLevel LoggingLevel;

// If enabled, the network priority for all SDK web requests will be set to low (this is good for network heavy apps). Default is NO. 
@property (nonatomic) BOOL NetworkPriorityIsLow;

// If it is set to YES then Interactables with render with page load metrics and other debug information. Default is NO. 
@property (nonatomic) BOOL DebugMode;

// Interactable display orientation. Default is SessionM_UIDisplayDynamic.
@property (nonatomic) SessionM_UIDisplayType orientation;

// Window to display interactable view in. Applications should only use this property when they have multiple windows and it is necessary to ensure that interactable is displayed in current key window. 
// Setting this property prompts SessionM to present interactable directly in the UIWindow object rather then by using view controller based mechanism.  
@property (nonatomic, retain) UIWindow *currentKeyWindow;

// View controller to use to display interactable from. Applications should only use this property when it is necessary to override default SDK mechanism of view display. 
// If neither currentKeyWindow nor currentViewController property is set Session M SDK determines current view controller by examining view controller display hierarchy and finds the topmost 
// view controller to present the interactable from. Note that presenting controller will receive viewWillDisappear: and viewWillAppear: messages when interactable is presented and dismissed, respectivelly. 
// Please, make sure that these methods handle interactable display appropriatelly. 
// If application does not use view controller for UI management the interactable view is displayed in key window. 
@property (nonatomic, retain) UIViewController *currentViewController;

@end



// User info dictionary keys names used in reporting user info state updates. See SessionMDelegate method userInfoDidChange: for more details.  

// Point balance. Value type is NSNumber.
extern NSString* const SessionMUserInfoPointBalanceKey;
// Opt out status. Value type is boolean as NSNumber. 
extern NSString* const SessionMUserInfoOptoutStatusKey;
// Achievement list. Value type is NSArray of NSDictionary objects. 
extern NSString* const SessionMUserInfoAchievememtsListKey;


// Achievement dictionary keys names. Achievement dictionary list is available via kSessionMUserInfoAchievememtsListKey in user info dictionary. 

// Achievement name. Value type is NSString. 
extern NSString* const SessionMUserInfoAchievememtNameKey;
// Achievement state. 
extern NSString* const SessionMUserInfoAchievememtStateKey;
// Achievement times earned. Vallue type is NSNumber. 
extern NSString* const SessionMUserInfoAchievememtTimesEarnedKey;


// Achievement states. These are the values kSessionMUserInfoAchievememtStateKey property.

// Unearned achievement. 
extern NSString* const SessionMUserInfoAchievememtStateUnearned;
// Claimed achievement. 
extern NSString* const SessionMUserInfoAchievememtStateClaimed;
// Unclaimed achievement. 
extern NSString* const SessionMUserInfoAchievememtStateUnclaimed;



@protocol SessionMDelegate <NSObject> 

@optional

// Notifies that SDK has fully initialized.
-(void)sessionMDidInitialize; 

// Notifies SDK initialization error. 
-(void)sessionMDidFail:(NSError*)error; 

// Notifies that interactable is about to be displayed on-screen. This delegate also gets passed YES if it will be shown or NO if it errored out.
-(void)interactableWillShow:(BOOL)willDisplay; 

// Notifies that interactable was requested and has started to load its content.
-(void)interactableDidStartLoad; 

// Notifies thatinteractable has started to display.
-(void)interactableDisplayStarted; 

// Notifies that interactable has finished loading all its content and is ready to be shown on screen.
-(void)interactableDidFinishLoad; 

// Notifies that full screen ad has started to load. 
-(void)interactableFullScreenDidStartLoad; 

// Notifies that user has interacted with the interactable (example: user has tapped "tap to claim").
-(void)userDidPerformInteraction; 

// Notifies that interactable view has been closed; this can happen either through user interaction or because the ad sequence has completed.
-(void)interactableDidClose; 

// Notifies that information about the user has changed. The userInfo dictionary contains keys with the preference name and their corresponding values.
-(void)userInfoDidChange:(NSDictionary*)userInfo; 


// Deprecated methods

// Notifies that event has successfully been sent and registered by the server. The event name in context is passed in as the withEvent parameter. 
-(void)sessionEventDidComplete:(NSString*)withEvent __attribute__((deprecated)); 

-(void)userAchievedAward:(NSString*)awardName withAmount:(int)awardAmount withType:(NSString*)awardType __attribute__((deprecated));  

@end



@interface SessionM : NSObject <SessionMDelegate> 

// SDK settings and configuration parameters.
+(Config*)config; 

// A flag that returns true if there is an interactable visible and on-screen.
+(BOOL)interactableIsShowing; 

// Initialize the SessionM sdk with a given application id.
+(void)initWithApplicationId:(NSString*)appId; 

// Delegate. Note that it is not retained by the SDK. 
+(id)delegate;
+(void)setDelegate:(id<SessionMDelegate>)newDelegate;

// Renders interactable view if it is available. 
+(void)insertInteractable; 

// Renders interactable view if it is available and logs event. 
+(void)insertInteractableWithEventName:(NSString*)EventName; 

// Renders interactable view if it is available with custom parameters. 
+(void)insertInteractable:(NSDictionary*)withParameters; 

// Renders user portal. 
+(void)summonPortal; 

// Dismisses interactable if it is displayed. 
+(void)dismissInteractable;

// Log an event. Logging event may enabled interactable display. 
+(void)sessionEvent:(NSString*)event_name; 

+(void)setMetaData:(NSString *)data forKey:(NSString *)key;

// logs application error and/or exception
// this method should be used as part of application exception handling logic, for example, in uncaught exception handler implementation 
// (see NSSetUncaughtExceptionHandler in Apple developer documentation)
+(void)logError:(NSString *)errorName message:(NSString *)message exception:(NSException *)exception;

+(NSString*)sdkVersion;

// returns YES if session M SDK supports this platform or OS version, NO - otheriwse
// application can examine this property to determine if it should initialize and use SessionM service
+(BOOL)isSupportedPlatform;

// Deprecated methods

// Deliver an award to the user from the pending awards list
+(void)deliverAward __attribute__((deprecated)); 

// Render an interactable that introduces a user to M-Points.
+(void)introduceMPoints __attribute__((deprecated)); 

// Update the user's location.
+(void)updateLocation:(NSString*)format latitude:(float)lat longitude:(float)lng __attribute__((deprecated)); 

@end

#endif /* __SESSIONM__ */
