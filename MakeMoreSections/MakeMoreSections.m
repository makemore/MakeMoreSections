//
//  MakeMoreSections.m
//  GetSiteSafePrototype
//
//  Created by Tim Barry on 07/06/2013.
//  Copyright (c) 2013 makemoredigital. All rights reserved.
//

#import "MakeMoreSections.h"

#import <objc/objc-runtime.h>
#import "NSObject+MMRuntime.h"
#import "MakeMoreSectionsDefaults.h"

@interface ProtocolAndMethodSignture : NSObject
@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, strong) NSMethodSignature *methodSignature;
@end

@implementation ProtocolAndMethodSignture
@end

@interface MakeMoreSections ()

@property (nonatomic, strong) NSDictionary *delegateSelectors;
@property (nonatomic, strong) NSDictionary *dataSourceSelectors;

@property (nonatomic, strong) NSDictionary *masterDelegateSelectors;
@property (nonatomic, strong) NSDictionary *masterDataSourceSelectors;

@property (nonatomic, strong) NSArray *sectionDelegates;
@property (nonatomic, strong) NSArray *sectionDataSources;

// respondsToSelector
- (NSDictionary *)_selectorDictionaryFromObjects:(NSArray *)objects respondingToProtocols:(NSArray *)protocols;

// forwarding tableview delegate/datasource methods
- (void)_tableViewForwardInvocation:(NSInvocation *)anInvocation;
- (NSInteger)_argumentIndexFromInvocation:(NSInvocation *)anInvocation;
- (NSNumber *)_sectionIndexFromArgumentAtIndex:(int)index ofInvocation:(NSInvocation*)anInvocation;
- (id)_targetForSelector:(SEL)selector atSectionIndex:(NSInteger)index;
- (id)_targetForSelector:(SEL)selector atSectionIndex:(NSInteger)index master:(id)master objects:(NSArray *)objects userDefault:(id)userDefault;

// forwarding scrollViewDelegate methods
- (void)_scrollViewDelegateForwardInvocation:(NSInvocation *)anInvocation;

@end


@implementation MakeMoreSections

- (id) initWithDataSources:(NSArray *)dataSources andDelegates:(NSArray *)delegates masterDataSource:(id<UITableViewDataSource>)masterDataSource masterDelegate:(id<UITableViewDelegate>)masterDelegate defaultDataSource:(id<UITableViewDataSource>)defaultDataSource defaultDelegate:(id<UITableViewDelegate>)defaultDelegate
{
    self = [super init];
    if (self) {
        self.dataSources = dataSources;
        self.delegates = delegates;
        self.masterDataSource = masterDataSource;
        self.masterDelegate = masterDelegate;
        self.defaultDataSource = defaultDataSource;
        self.defaultDelegate = defaultDelegate;
    }
    return self;
}

- (id)initWithSections:(NSArray *)sections master:(id<UITableViewDataSource,UITableViewDelegate>)master default:(id<UITableViewDataSource,UITableViewDelegate>)fallback
{
    return [self initWithDataSources:sections andDelegates:sections masterDataSource:master masterDelegate:master defaultDataSource:fallback defaultDelegate:fallback];
}


- (NSIndexPath *)relativeIndexPathFromIndexPath:(NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:[self relativeSectionFromSection:indexPath.section]];
}

- (NSInteger)relativeSectionFromSection:(NSInteger)section
{
    id object = [self.dataSources objectAtIndex:section];
    NSUInteger lowestIndexOfIdenticalObject = [self.dataSources indexOfObjectIdenticalTo:object];
    
    return section - lowestIndexOfIdenticalObject;
}

- (void)setDataSources:(NSArray *)dataSources
{
    if (_dataSources != dataSources) {
        _dataSources = dataSources;
        self.dataSourceSelectors = [self _selectorDictionaryFromObjects:dataSources respondingToProtocols:@[@protocol(UITableViewDataSource)]];
    }
}

- (void)setDelegates:(NSArray *)delegates
{
    if (_delegates != delegates) {
        _delegates = delegates;
        self.delegateSelectors = [self _selectorDictionaryFromObjects:delegates respondingToProtocols:@[@protocol(UITableViewDelegate),@protocol(UIScrollViewDelegate)]];
    }
}

- (void)setMasterDataSource:(id<UITableViewDataSource>)masterDataSource
{
    if (_masterDataSource != masterDataSource) {
        _masterDataSource = masterDataSource;
        self.masterDataSourceSelectors = [self _selectorDictionaryFromObjects:@[masterDataSource] respondingToProtocols:@[@protocol(UITableViewDataSource)]];
    }
}

- (void)setMasterDelegate:(id<UITableViewDelegate>)masterDelegate
{
    if (_masterDelegate != masterDelegate) {
        _masterDelegate = masterDelegate;
        self.masterDelegateSelectors = [self _selectorDictionaryFromObjects:@[masterDelegate] respondingToProtocols:@[@protocol(UITableViewDelegate),@protocol(UIScrollViewDelegate)]];
    }
}


- (NSDictionary *)_selectorDictionaryFromObjects:(NSArray *)objects respondingToProtocols:(NSArray *)protocols
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [NSObject enumerateMethodDescriptionsInProtocols:protocols usingBlock:^(struct objc_method_description method, Protocol *protocol, BOOL isRequiredMethod) {
        
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:method.name]) {
                
                ProtocolAndMethodSignture *protocolAndMethodSignture = [[ProtocolAndMethodSignture alloc] init];
                protocolAndMethodSignture.protocol = protocol;
                protocolAndMethodSignture.methodSignature = [NSMethodSignature signatureWithObjCTypes:method.types];
                
                [dictionary setObject:protocolAndMethodSignture forKey:NSStringFromSelector(method.name)];
                
                //NSLog(@"%@ %@", NSStringFromSelector(method.name), NSStringFromProtocol(protocol));
                *stop = TRUE;
            }
        }];
    }];
    return dictionary;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([[self.delegateSelectors allKeys] containsObject:selectorString] || [[self.dataSourceSelectors allKeys] containsObject:selectorString] ||
        [[self.masterDelegateSelectors allKeys] containsObject:selectorString] || [[self.masterDataSourceSelectors allKeys] containsObject:selectorString]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    ProtocolAndMethodSignture *pAndM = ([self.dataSourceSelectors objectForKey:NSStringFromSelector(aSelector)]) ?
    [self.dataSourceSelectors objectForKey:NSStringFromSelector(aSelector)] :
    [self.delegateSelectors objectForKey:NSStringFromSelector(aSelector)];
    if (pAndM.methodSignature) {
        return pAndM.methodSignature;
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([NSObject protocol:@protocol(UIScrollViewDelegate) declaresSelector:anInvocation.selector])
    {
        [self _scrollViewDelegateForwardInvocation:anInvocation];
    }
    else
    {
        [self _tableViewForwardInvocation:anInvocation];
    }
}

#pragma mark - private methods

// handle all forwardInvocations for all scrollViewDelegate methods without a return type...
- (void)_scrollViewDelegateForwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.masterDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.masterDelegate];
    }
    for (id target in self.sectionDelegates) {
        if ([target respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:target];
        }
    }
}

- (void)_tableViewForwardInvocation:(NSInvocation *)anInvocation
{
    NSInteger argumentIndex = [self _argumentIndexFromInvocation:anInvocation];
    
    if (argumentIndex > 1) { //0:self 1:selector 2:first custom arg
        NSNumber *section = [self _sectionIndexFromArgumentAtIndex:argumentIndex ofInvocation:anInvocation];
        
        if (section) {
            NSInteger sectionIndex = [[self _sectionIndexFromArgumentAtIndex:argumentIndex ofInvocation:anInvocation] integerValue];
            id target = [self _targetForSelector:anInvocation.selector atSectionIndex:sectionIndex];
            if (target) {
                [anInvocation invokeWithTarget:target];
            }
        }
    }
}

- (NSInteger)_argumentIndexFromInvocation:(NSInvocation *)anInvocation
{
    NSString *selector = NSStringFromSelector(anInvocation.selector);    
    NSArray *argumentNames = [selector componentsSeparatedByString:@":"];    
    __block NSInteger argumentIndex;
    
    [argumentNames enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *argumentName, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"%@", argumentName);
        
        if (([argumentName rangeOfString:@"IndexPath"].location != NSNotFound) ||
            ([argumentName rangeOfString:@"Section"].location != NSNotFound))
        {
            argumentIndex = 2 + idx;
            *stop = TRUE;
        }
    }];
    return argumentIndex;
}

- (NSNumber *)_sectionIndexFromArgumentAtIndex:(int)index ofInvocation:(NSInvocation*)anInvocation;
{
	const char* argType;
	argType = [[anInvocation methodSignature] getArgumentTypeAtIndex:index];
    while(strchr("rnNoORV", argType[0]) != NULL)
		argType += 1;
	
	if((strlen(argType) > 1) && (strchr("{^", argType[0]) == NULL) && (strcmp("@?", argType) != 0))
		[NSException raise:NSInvalidArgumentException format:@"Cannot handle argument type '%s'.", argType];
    
	switch (argType[0])
	{
		case '@':
		{
			NSIndexPath __unsafe_unretained *indexPath;
			[anInvocation getArgument:&indexPath atIndex:index];
            if (self.relativeIndexPaths) {
                NSIndexPath *relativeIndexPath = [self relativeIndexPathFromIndexPath:indexPath];
                [anInvocation setArgument:&relativeIndexPath atIndex:index];
            }
			return @(indexPath.section);
		}
		case 'i':
		{
			int section;
			[anInvocation getArgument:&section atIndex:index];
            if (self.relativeIndexPaths) {
                NSInteger relativeSection = [self relativeSectionFromSection:section];
                [anInvocation setArgument:&relativeSection atIndex:index];
            }
			return @(section);
		}
	}
	return nil;
}


- (id)_targetForSelector:(SEL)selector atSectionIndex:(NSInteger)index
{
    if (index < 0) {
        return nil;
    }
    ProtocolAndMethodSignture *protocolAndMethodSignture =  [self.delegateSelectors objectForKey:NSStringFromSelector(selector)];
    
    if (protocolAndMethodSignture) {
        return [self _targetForSelector:selector atSectionIndex:index master:self.masterDelegate objects:self.sectionDelegates userDefault:self.defaultDelegate];
    }
    else
    {
        return [self _targetForSelector:selector atSectionIndex:index master:self.masterDataSource objects:self.sectionDataSources userDefault:self.defaultDataSource];
    }
}

- (id)_targetForSelector:(SEL)selector atSectionIndex:(NSInteger)index master:(id)master objects:(NSArray *)objects userDefault:(id)userDefault
{
    if ([master respondsToSelector:selector]) {
        return master;
    }
    else if (index < objects.count &&
             [[objects objectAtIndex:index] respondsToSelector:selector])
    {
        return [objects objectAtIndex:index];
    }
    else if ([userDefault respondsToSelector:selector])
    {
        return userDefault;
    }
    else if ([[MakeMoreSectionsDefaults sharedDefault] respondsToSelector:selector])
    {
        return [MakeMoreSectionsDefaults sharedDefault];
    }
    return nil;
}

#pragma mark - forwarding segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id delegate = nil;
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        UITableView *tableView;
        if ([self respondsToSelector:@selector(tableView)]) {
            tableView = [self performSelector:@selector(tableView)];
        }
        NSIndexPath *indexPath = [tableView indexPathForCell:sender];
        delegate = [self.sectionDelegates objectAtIndex:indexPath.section];
    }
    else if ([self.sectionDelegates containsObject:sender])
    {
        delegate = sender;
    }
    if ([delegate respondsToSelector:_cmd])
    {
        [delegate prepareForSegue:segue sender:sender];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id delegate = [self.sectionDelegates objectAtIndex:indexPath.section];
        
        if ([delegate respondsToSelector:_cmd])
        {
            return [delegate shouldPerformSegueWithIdentifier:identifier sender:sender];
        }
    }
    return YES;
}


#pragma mark - @protocol UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *sectionDelegates = [NSMutableArray array];
    NSMutableArray *sectionDataSources = [NSMutableArray array];
    [self.dataSources enumerateObjectsUsingBlock:^(id <UITableViewDataSource> dataSource, NSUInteger idx, BOOL *stop) {
        
        NSUInteger sectionsInDatasource = ([dataSource respondsToSelector:_cmd]) ? [dataSource numberOfSectionsInTableView:tableView] : 1; // if datasource does respond default is 1
        id <UITableViewDelegate> delegate = [self.delegates objectAtIndex:idx];
        for (NSUInteger i = 0; i < sectionsInDatasource; i++)
        {
            [sectionDataSources addObject:dataSource];
            [sectionDelegates addObject:delegate];
        }
    }];
    
    self.sectionDelegates = sectionDelegates;
    self.sectionDataSources = sectionDataSources;

    NSLog(@"sections: %d", [self.dataSources count]);
    NSLog(@"allSections: %d", self.sectionDataSources.count);
    
    return [self.sectionDataSources count];
}

#pragma mark - @protocol UIScrollViewDelegate


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // if any section returns NO return NO otherwise YES
    for (id <UITableViewDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:_cmd] && [delegate scrollViewShouldScrollToTop:scrollView] == NO) {
            return NO;
        }
    }
    return YES;
}

@end


