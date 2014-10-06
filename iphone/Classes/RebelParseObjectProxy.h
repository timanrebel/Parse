/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <Parse/Parse.h>

@interface RebelParseObjectProxy : TiProxy

@property(nonatomic,readwrite,assign) PFObject* pfObject;

-(void)saveObject;
-(void)saveEventually;
-(void)saveInBackground:(id)args;

-(void)fetchInBackground:(id)args;
-(void)refreshInBackground:(id)args;
-(void)deleteInBackground:(id)args;

-(NSString *)objectId;
-(NSDate *)createdAt;
-(NSDate *)updatedAt;

-(id)getValue:(id)args;
-(void)set:(id)args;



@end
