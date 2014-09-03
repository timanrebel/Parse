/**
 * Parse
 *
 * Created by Timan Rebel
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "RebelParseModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#import "JRSwizzle.h"


// Create a category which adds new methods to TiApp
@implementation TiApp (Facebook)

- (void)parseApplicationDidBecomeActive:(UIApplication *)application
{
    // If you're successful, you should see the following output from titanium
    NSLog(@"[DEBUG] RebelFacebookModule#applicationDidBecomeActive");
    
    // be sure to call the original method
    // note: swizzle will 'swap' implementations, so this is calling the original method,
    // not the current method... so this will not infinitely recurse. promise.
    [self parseApplicationDidBecomeActive:application];
    
    // Add your custom code here...
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

@end

@implementation RebelParseModule

// This is the magic bit... Method Swizzling
// important that this happens in the 'load' method, otherwise the methods
// don't get swizzled early enough to actually hook into app startup.
+ (void)load {
    NSError *error = nil;
    
    [TiApp jr_swizzleMethod:@selector(applicationDidBecomeActive:)
                 withMethod:@selector(parseApplicationDidBecomeActive:)
                      error:&error];
    if(error)
        NSLog(@"[WARN] Cannot swizzle application:openURL:sourceApplication:annotation: %@", error);
}

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"e700fd13-7783-4f1c-9201-1442922524fc";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"rebel.Parse";
}

#pragma mark Lifecycle

-(void)startup
{
    NSDictionary *launchOptions = [[TiApp app] launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    [Parse setApplicationId:@"lv1RFFzbmJuCYAZigzkbLAtCEqDVIQCtm3u5VI63"
                  clientKey:@"yqPZaWARkGkLeuMZuZDze6Cy2S72DaWmvMpLqx53"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

@end
