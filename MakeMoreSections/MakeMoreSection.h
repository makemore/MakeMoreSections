//
//  MMSection.h
//  MMSections
//
//  Created by tim on 22/11/2012.
//  Copyright (c) 2012 makemoredigital. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MakeMoreSection <UITableViewDataSource, UITableViewDelegate, NSObject>

- (id)initWithViewController:(UIViewController *)viewController andTableView:(UITableView *)tableView;

@optional

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end

@interface MakeMoreSection : NSObject <MakeMoreSection>

@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) UITableView *tableView;

- (id)initWithViewController:(UIViewController *)viewController andTableView:(UITableView *)tableView;

@end


