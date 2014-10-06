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
    NSLog(@"[DEBUG] RebelParseModule#applicationDidBecomeActive");
    
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
        NSLog(@"[ERROR] Cannot swizzle application:openURL:sourceApplication:annotation: %@", error);
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *launchOptions = [[TiApp app] launchOptions];
    
    NSString *applicationId = [[TiApp tiAppProperties] objectForKey:@"rebel.parse.appId"];
    NSString *clientKey = [[TiApp tiAppProperties] objectForKey:@"rebel.parse.clientKey"];
    
    NSLog(@"appId: %@", applicationId);
    NSLog(@"clientKey: %@", clientKey);
    
    [Parse setApplicationId:applicationId
                  clientKey:clientKey];
    
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Set default ACL
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
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
    
    [[PFFacebookUtils session] close];
}

-(void)resumed:(id)note
{
	NSLog(@"[DEBUG] facebook resumed");
    
    NSDictionary *launchOptions = [[TiApp app] launchOptions];
    if (launchOptions != nil)
    {
        NSString *urlString = [launchOptions objectForKey:@"url"];
        NSString *sourceApplication = [launchOptions objectForKey:@"source"];
        
        if (urlString != nil) {
            return [FBAppCall handleOpenURL:[NSURL URLWithString:urlString]
                          sourceApplication:sourceApplication
                                withSession:[PFFacebookUtils session]];
        }
    }
    
    return NO;
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

#pragma Authentication
- (void)signup:(id)args
{
    PFUser *user = [PFUser user];
    user.username = @"my name";
    user.password = @"my pass";
    user.email = @"email@example.com";
    
    // other fields can be set just like with PFObject
    user[@"phone"] = @"415-392-0202";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
        }
    }];
}

-(void)login:(id)args
{
    [PFUser logInWithUsernameInBackground:@"myname" password:@"mypass"
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                        } else {
                                            // The login failed. Check error to see why.
                                        }
                                    }];
}

-(void)logout:(id)args
{
    [PFUser logOut];
}

-(void)resetPassword:(id)email
{
    ENSURE_SINGLE_ARG(email, NSString);
    
    [PFUser requestPasswordResetForEmailInBackground:email];
}

-(id)currentUser
{
    if(currentUser == nil && [PFUser currentUser] != nil) {
        currentUser = [[RebelParseUserProxy alloc]init];
        currentUser.pfObject = [[PFUser currentUser] retain];
    }
    
    return currentUser;
}

#pragma Facebook
// Login PFUser using Facebook
-(void)loginWithFacebook:(id)args
{
    NSArray *permissions;
    KrollCallback *callback;
    
    ENSURE_ARG_AT_INDEX(permissions, args, 0, NSArray);
    ENSURE_ARG_OR_NIL_AT_INDEX(callback, args, 1, KrollCallback);
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            
            RebelParseUserProxy *currentUser = [[RebelParseUserProxy alloc]init];
            currentUser.pfObject = [user retain];
            
            if(callback) {
                NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:currentUser, @"user", nil];
                
                [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
            }
        }
    }];
}

-(void)loginWithFacebookAccessTokenData:(id)args
{
    NSDictionary *accessTokenData;
    
    ENSURE_ARG_AT_INDEX(accessTokenData, args, 0, NSDictionary);
    
    [PFFacebookUtils logInWithFacebookId:[accessTokenData objectForKey:@"facebookId"]
                            accessToken:[accessTokenData objectForKey:@"accessToken"]
                            expirationDate:[accessTokenData objectForKey:@"expirationDate"]
                                   block: ^(PFUser *user, NSError *error) {
                                       
       if (!user) {
           NSString *errorMessage = nil;
           if (!error) {
               NSLog(@"Uh oh. The user cancelled the Facebook login.");
               
           } else {
               NSLog(@"Uh oh. An error occurred: %@", error);
               errorMessage = [error localizedDescription];
               
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                               message:errorMessage
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Dismiss", nil];
               [alert show];
           }
       } else {
           if (user.isNew) {
               NSLog(@"User with facebook signed up and logged in!");
           } else {
               NSLog(@"User with facebook logged in!");
           }
       }
   }];
}

#pragma Cloud functions
-(void)callFunction:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *function = [args objectForKey:@"function"];
    NSDictionary *params = [args objectForKey:@"params"];
    KrollCallback *callback = [args objectForKey:@"callback"];
    
    [PFCloud callFunctionInBackground:function
                       withParameters:@{}
                                block:^(id result, NSError *error) {
                                    if([result isKindOfClass:[PFObject class]]) {
//                                        result = [self convertPFObjectToNSDictionary:object];
                                    }
                                    
                                    NSMutableArray *objects = [[NSMutableArray alloc] init];
                                    for (id object in result) {
                                        RebelParseObjectProxy *pfObject = [[RebelParseObjectProxy alloc]init];
                                        pfObject.pfObject = [object retain];
                                        
                                        [objects addObject:pfObject];
                                    }
                                    
                                    if (!error) {
                                        NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:objects, @"result", nil];
                                        
                                        [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
                                    }
                                }];
}

#pragma Location
-(void)getLocation:(id)args
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
        }
    }];
}

#pragma Events
-(void)trackEvent:(id)args
{
    NSString *event;
    NSDictionary *properties;
    
    ENSURE_ARG_AT_INDEX(event, args, 0, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(properties, args, 1, NSDictionary);
    
    [PFAnalytics trackEvent:event dimensions:properties];
}

#pragma Push Notifications
-(void)registerDeviceToken:(id)deviceToken
{
    ENSURE_SINGLE_ARG(deviceToken, NSString);
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:[deviceToken dataUsingEncoding:NSUTF8StringEncoding]];
    [currentInstallation saveInBackground];
}

-(void)subscribeChannel:(id)channel
{
    ENSURE_SINGLE_ARG(channel, NSString);
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

-(void)unsubscribeChannel:(id)channel
{
    ENSURE_SINGLE_ARG(channel, NSString);
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

-(NSArray *)getChannels:(id)args
{
    return [PFInstallation currentInstallation].channels;
}

@end
