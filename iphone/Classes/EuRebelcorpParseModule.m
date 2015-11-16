/**
 * Parse
 *
 * Created by Timan Rebel
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "EuRebelcorpParseModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation EuRebelcorpParseModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"e700fd13-7783-4f1c-9201-1442922524fc";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"eu.rebelcorp.parse";
}

#pragma mark Lifecycle

-(void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationOpened:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

-(void)startup
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *launchOptions = [[TiApp app] launchOptions];
    
    NSString *applicationId = [[TiApp tiAppProperties] objectForKey:@"Parse_AppId"];
    NSString *clientKey = [[TiApp tiAppProperties] objectForKey:@"Parse_ClientKey"];
    
    NSLog(@"Initializing with: %@, %@", applicationId, clientKey);
    
    [Parse setApplicationId:applicationId
                  clientKey:clientKey];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
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


#pragma User

-(void)login:(id)args
{
    NSString *username = [args objectAtIndex:0];
    NSString *password = [args objectAtIndex:1];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
        } else {
            // The login failed. Check error to see why.
        }
    }];
}

-(void)logout
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

#pragma Push Notifications
-(void)notificationOpened:(NSNotification *)userInfo {
    NSLog(@"Notification opened");
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:[userInfo userInfo]];
}

-(void)registerDeviceToken:(id)deviceToken
{
    ENSURE_SINGLE_ARG(deviceToken, NSString);
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:[deviceToken dataUsingEncoding:NSUTF8StringEncoding]];
    [currentInstallation saveInBackground];
}

-(void)registerForPush:(id)args {
    ENSURE_ARG_COUNT(args, 3);
    
    NSString *deviceToken = [args objectAtIndex:0];
    NSString *channel = [args objectAtIndex:1];
    KrollCallback *callback = [args objectAtIndex:2];
    
    NSLog(@"Register for push notification on channel %@ with device token %@", channel, deviceToken);
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceToken:deviceToken];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        if (callback) {
            NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:success], @"success", [error userInfo], @"error", nil];
            [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:nil];
        }
    }];
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

-(void)putValue:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_TYPE([args objectAtIndex:0], NSString);
    ENSURE_TYPE([args objectAtIndex:1], NSObject);
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addObject:[args objectAtIndex:1] forKey:[args objectAtIndex:0]];
    [currentInstallation saveInBackground];
}

#pragma Property getter
-(NSString *)currentInstallationId
{
    return [PFInstallation currentInstallation].installationId;
}

-(NSString *)objectId
{
    return [PFInstallation currentInstallation].objectId;
}

-(NSArray *)channels:(id)args
{
    return [PFInstallation currentInstallation].channels;
}

@end
