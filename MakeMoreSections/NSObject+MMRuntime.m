//
//  NSObject+MMRuntime.m
//  TestRuntime
//
//  Created by Tim Barry on 08/03/2013.
//  Copyright (c) 2013 Tim Barry. All rights reserved.
//

#import "NSObject+MMRuntime.h"

@implementation NSObject (MMRuntime)

+ (void)enumerateMethodDescriptionsInProtocol:(Protocol *)protocol requiredMethod:(BOOL)isRequiredMethod usingBlock:(void (^)(struct objc_method_description, Protocol *, BOOL))block
{
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, YES, &count);
    
    for(unsigned i = 0; i < count; i++)
    {
        block(methods[i], protocol, isRequiredMethod);
    }
    free(methods);
}

+ (void)enumerateMethodDescriptionsInProtocol:(Protocol *)protocol usingBlock:(void (^)(struct objc_method_description, Protocol *, BOOL))block
{
    [self enumerateMethodDescriptionsInProtocol:protocol requiredMethod:YES usingBlock:block];
    [self enumerateMethodDescriptionsInProtocol:protocol requiredMethod:NO usingBlock:block];
}

+ (void)enumerateMethodDescriptionsInProtocols:(NSArray *)protocols requiredMethod:(BOOL)isRequiredMethod usingBlock:(void (^)(struct objc_method_description, Protocol *, BOOL))block
{
    for (Protocol *protocol in protocols) {
        [self enumerateMethodDescriptionsInProtocol:protocol requiredMethod:isRequiredMethod usingBlock:block];
    }
}

+ (void)enumerateMethodDescriptionsInProtocols:(NSArray *)protocols usingBlock:(void (^)(struct objc_method_description, Protocol *, BOOL))block
{
    [self enumerateMethodDescriptionsInProtocols:protocols requiredMethod:YES usingBlock:block];
    [self enumerateMethodDescriptionsInProtocols:protocols requiredMethod:NO usingBlock:block];
}



+ (BOOL)protocol:(Protocol *)protocol declaresSelector:(SEL)selector
{
    
    struct objc_method_description required = protocol_getMethodDescription(protocol, selector, YES, YES);
    struct objc_method_description optional = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    
    
    NSLog(@"protocol %@  selector %@ required:%@ optional:%@", NSStringFromProtocol(protocol), NSStringFromSelector(selector),  NSStringFromSelector(required.name),  NSStringFromSelector(optional.name));
    
    
    
    
    if (protocol_getMethodDescription(protocol, selector, YES, YES).name != nil
        || protocol_getMethodDescription(protocol, selector, NO, YES).name != nil)
    {
        return YES;
    }
    return NO;
}

+ (NSArray *)protocolsInProtocols:(NSArray *)protocols declaringSelector:(SEL)selector
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:protocols.count];
    for (Protocol *protocol in protocols) {
        if ([self protocol:protocol declaresSelector:selector]) {
            [array addObject:protocol];
        }
    }
    return array;
}

@end
