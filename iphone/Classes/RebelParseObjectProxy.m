/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "RebelParseObjectProxy.h"

@implementation RebelParseObjectProxy

@synthesize pfObject;

-(id)init
{
    // Enable delegate
    self.modelDelegate = self;
	
	return [super init];
}

-(void)dealloc
{
	RELEASE_TO_NIL(pfObject);
	
	[super dealloc];
}

/**
 * Initialize PFObject based on given className and attributes
 */
-(void)_initWithProperties:(NSDictionary *)properties
{
    [super _initWithProperties:properties];
    
	NSString *className;
    NSDictionary *attributes;
    
    ENSURE_ARG_FOR_KEY(className, properties, @"className", NSString);
    ENSURE_ARG_OR_NIL_FOR_KEY(attributes, properties, @"properties", NSDictionary);
    
    if(attributes != nil) {
        pfObject = [[PFObject objectWithClassName:className dictionary:attributes] retain];
    }
    else
        pfObject = [[PFObject objectWithClassName:className] retain];
}

#pragma Save functions
-(void)saveObject:(id)args
{
   [pfObject save];
}

-(void)saveEventually:(id)args
{
    [pfObject saveEventually];
}

-(void)saveInBackground:(id)args
{
    KrollCallback *callback;
    ENSURE_ARG_OR_NIL_AT_INDEX(callback, args, 0, KrollCallback);
    
    [pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
            NSLog(@"Success :)");
    
        if(callback) {
            NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
            
            [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
        }
    }];
}

-(void)fetchInBackground:(id)args
{
    KrollCallback *callback;
    ENSURE_ARG_OR_NIL_AT_INDEX(callback, args, 0, KrollCallback);
    
    [pfObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(callback) {
            NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
            
            [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
        }
    }];
}

-(void)refreshInBackground:(id)args
{
    KrollCallback *callback;
    ENSURE_ARG_OR_NIL_AT_INDEX(callback, args, 0, KrollCallback);
    
    [pfObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(callback) {
            NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
            
            [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
        }
    }];
}

-(void)deleteInBackground:(id)args
{
    KrollCallback *callback;
    ENSURE_ARG_OR_NIL_AT_INDEX(callback, args, 0, KrollCallback);
    
    [pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(callback) {
            NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
            
            [self _fireEventToListener:@"completed" withObject:result listener:callback thisObject:self];
        }
    }];
}

#pragma Getters
-(id)objectId
{
    return pfObject.objectId;
}

-(id)createdAt
{
    return pfObject.createdAt;
}

-(id)updatedAt
{
    return pfObject.updatedAt;
}

-(id)getValue:(id)args
{
    NSString *key;
    
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);

    return [pfObject objectForKey:key];
}

#pragma Setters
-(void)set:(id)args
{
    NSString *key;
    
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_ARG_AT_INDEX(key, args, 0, NSString);
    
    id newValue = [args objectAtIndex:1];
    id oldValue = [pfObject objectForKey:key];
    
    [pfObject setObject:newValue forKey:key];
    NSLog(@"Set");
    
    // Fire change event
	if ([self _hasListeners:@"change"]) {
		NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
							   key, @"property",
							   oldValue == nil ? [NSNull null] : oldValue, @"oldValue",
							   newValue == nil ? [NSNull null] : newValue, @"newValue",
							   nil
							   ];
		[self fireEvent:@"change" withObject:event];
	}
}

/**
 * Setter for all non defined properties
 */
-(void)propertyChanged:(NSString*)key oldValue:(id)oldValue newValue:(id)newValue proxy:(TiProxy*)proxy
{
	if ([oldValue isEqual:newValue]) {
		// Value didn't really change
		return;
	}
	
	NSLog(@"[DEBUG] Property %@ changed from %@ to %@", key, oldValue, newValue);
    
    pfObject[key] = newValue;
    
    // Fire change event
	if ([self _hasListeners:@"change"]) {
		NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
							   key, @"property",
							   oldValue == nil ? [NSNull null] : oldValue, @"oldValue",
							   newValue == nil ? [NSNull null] : newValue, @"newValue",
							   nil
							   ];
		[self fireEvent:@"change" withObject:event];
	}
}

@end
