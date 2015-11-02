/**
 * Parse
 *
 * Created by Timan Rebel
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "RebelParseUserProxy.h"

#import <Parse/Parse.h>

@interface EuRebelcorpParseModule : TiModule {
@private
    RebelParseUserProxy* currentUser;
}

-(void)login:(id)args;
-(void)logout;
-(void)resetPassword:(id)args;

@end
