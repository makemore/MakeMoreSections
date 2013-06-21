//
//  MMSection.m
//  MMSections
//
//  Created by tim on 22/11/2012.
//  Copyright (c) 2012 makemoredigital. All rights reserved.
//

#import "MakeMoreSection.h"

@interface MakeMoreSection ()

@property (nonatomic, readwrite) UIViewController *viewController;
@property (nonatomic, readwrite) UITableView *tableView;

@end


@implementation MakeMoreSection

- (id)initWithViewController:(UIViewController *)viewController andTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
    }
    return self;
}

@end
