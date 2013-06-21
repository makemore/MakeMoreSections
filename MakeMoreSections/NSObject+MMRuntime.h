//
//  NSObject+MMRuntime.h
//  TestRuntime
//
//  Created by Tim Barry on 08/03/2013.
//  Copyright (c) 2013 Tim Barry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>

@interface NSObject (MMRuntime)

typedef void (^ParamsBlock)(struct objc_method_description method, Protocol *protocol, BOOL isRequiredMethod);


+ (void)enumerateMethodDescriptionsInProtocol:(Protocol *)protocol
                               requiredMethod:(BOOL)isRequiredMethod
                                   usingBlock:(void (^)(struct objc_method_description method, Protocol *protocol, BOOL isRequiredMethod))block;


+ (void)enumerateMethodDescriptionsInProtocol:(Protocol *)protocol
                                   usingBlock:(void (^)(struct objc_method_description method, Protocol *protocol, BOOL isRequiredMethod))block;;


+ (void)enumerateMethodDescriptionsInProtocols:(NSArray *)protocols
                                requiredMethod:(BOOL)isRequiredMethod
                                    usingBlock:(void (^)(struct objc_method_description method, Protocol *protocol, BOOL isRequiredMethod))block;

+ (void)enumerateMethodDescriptionsInProtocols:(NSArray *)protocols
                                    usingBlock:(void (^)(struct objc_method_description method, Protocol *protocol, BOOL isRequiredMethod))block;


+ (BOOL)protocol:(Protocol *)protocol declaresSelector:(SEL)selector;

+ (NSArray *)protocolsInProtocols:(NSArray *)protocols declaringSelector:(SEL)selector;


@end
