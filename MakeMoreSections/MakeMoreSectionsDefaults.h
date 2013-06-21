//
//  MMTableViewSectionsDefaults.h
//  GetSiteSafePrototype
//
//  Created by Tim Barry on 13/03/2013.
//  Copyright (c) 2013 makemoredigital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeMoreSectionsDefaults : NSObject <UITableViewDataSource, UITableViewDelegate>

+ (instancetype)sharedDefault;

@end
