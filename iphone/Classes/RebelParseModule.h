/**
 * Parse
 *
 * Created by Timan Rebel
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "RebelParseUserProxy.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface RebelParseModule : TiModule {
@private
    RebelParseUserProxy* currentUser;
}



-(void)signup:(id)args;
-(void)login:(id)args;
-(void)logout;
-(void)resetPassword:(id)args;

-(void)loginWithFacebook:(id)args;
-(void)callFunction:(id)args;

@end
