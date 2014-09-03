/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "RebelParseQueryProxy.h"

@implementation RebelParseQueryProxy

@synthesize query;

MAKE_SYSTEM_PROP(cachePolicyIgnoreCache, kPFCachePolicyIgnoreCache);
MAKE_SYSTEM_PROP(cachePolicyCacheOnly, kPFCachePolicyCacheOnly);
MAKE_SYSTEM_PROP(cachePolicyNetworkOnly, kPFCachePolicyNetworkOnly);
MAKE_SYSTEM_PROP(cachePolicyCacheElseNetwork, kPFCachePolicyCacheElseNetwork);
MAKE_SYSTEM_PROP(cachePolicyNetworkElseCache, kPFCachePolicyNetworkElseCache);
MAKE_SYSTEM_PROP(cachePolicyCacheThenNetwork, kPFCachePolicyCacheThenNetwork);

-(void)dealloc
{
    RELEASE_TO_NIL(query);
    
    [super dealloc];
}

-(void)_initWithProperties:(NSDictionary *)properties
{
    [super _initWithProperties:properties];
    
    NSString *className;
    
    ENSURE_ARG_FOR_KEY(className, properties, @"className", NSString);
	
    query = [[PFQuery queryWithClassName:className] retain];
}

#pragma getObject
-(void)getObjectWithId:(id)args
{
    NSString *objectId;
    KrollCallback *callback;

    ENSURE_ARG_AT_INDEX(objectId, args, 0, NSString);
    ENSURE_ARG_AT_INDEX(callback, args, 1, KrollCallback);
    
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *gameScore, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"%@", gameScore);
        
        RebelParseObjectProxy *object = [[RebelParseObjectProxy alloc]init];
        object.pfObject = [gameScore retain];
        
        NSLog(@"%@", object);
        NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:object, @"object", nil];
//        NSArray *array = [NSArray arrayWithObjects:object,nil];
        
//        [callback call:array thisObject:nil];
        [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
    }];
}

-(void)find:(id)args
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


#pragma Query criteria
-(void)equalTo:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id value = [args objectAtIndex:1];
    
    [query whereKey:key equalTo:value];
}

-(void)notEqualTo:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id value = [args objectAtIndex:1];
    
    [query whereKey:key notEqualTo:value];
}

-(void)greaterThan:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id value = [args objectAtIndex:1];
    
    [query whereKey:key greaterThan:value];
}

-(void)lessThan:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id value = [args objectAtIndex:1];
    
    [query whereKey:key lessThan:value];
}

#pragma ordering
-(void)limit:(id)args
{
    NSNumber *limit;
    
    ENSURE_ARG_AT_INDEX(limit, args, 0, NSNumber);
    
    query.limit = limit;
}

-(void)skip:(id)args
{
    NSNumber *skip;
    
    ENSURE_ARG_AT_INDEX(skip, args, 0, NSNumber);
    
    query.limit = skip;
}

-(void)addAscendingOrder:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id value = [args objectAtIndex:1];
    
    [query whereKey:key equalTo:value];
}

-(void)addDescendingOrder:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id value = [args objectAtIndex:1];
    
    [query whereKey:key equalTo:value];
}

#pragma Caching
-(BOOL)hasCachedResult
{
    return [query hasCachedResult];
}

-(void)clearCachedResult
{
    [query clearCachedResult];
}

-(void)clearAllCachedResults
{
    [PFQuery clearAllCachedResults];
}

-(void)setCachePolicy:(id)policy
{
    NSLog(@"%@", policy);
    
    query.cachePolicy = policy;
}

-(void)setMaxCacheAge:(double)value
{
    NSLog(@"%@", value);
    
    query.maxCacheAge = value;
}


@end
