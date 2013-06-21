//
//  MakeMoreSections.h
//  GetSiteSafePrototype
//
//  Created by Tim Barry on 07/06/2013.
//  Copyright (c) 2013 makemoredigital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MakeMoreSections : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)      id <UITableViewDataSource> masterDataSource;    // overrides any section datasources
@property (nonatomic, weak)      id <UITableViewDelegate>   masterDelegate;      // overrides any section delegate
@property (nonatomic, weak)      id <UITableViewDataSource> defaultDataSource;   // fallback if a method is implemented by 1 section and not the other. (typically for return type methods) if nil using internal default
@property (nonatomic, weak)      id <UITableViewDelegate>   defaultDelegate;     // fallback if a method is implemented by 1 section and not the other. (typically for return type methods) if nil using internal default

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *delegates;
@property (nonatomic, strong) NSArray *dataSources;

@property (nonatomic) BOOL relativeIndexPaths;

- (id)initWithDataSources:(NSArray *)dataSources // dataSources  should be (id <UITableViewDataSource>)
          andDelegates:(NSArray *)delegates // delegates    should be (id <UITableViewDelegate>)
      masterDataSource:(id <UITableViewDataSource>)masterDataSource
        masterDelegate:(id <UITableViewDelegate>)masterDelegate
     defaultDataSource:(id <UITableViewDataSource>)defaultDataSource
       defaultDelegate:(id <UITableViewDelegate>)defaultDelegate;

// convenience for when the same object is delegate and datasource
- (id)initWithSections:(NSArray *)sections // sections should be (id <UITableViewDataSource, UITableViewDelegate>)
                master:(id <UITableViewDataSource, UITableViewDelegate>)master
               default:(id <UITableViewDataSource, UITableViewDelegate>)fallback;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;


/* // need to work on unwind segues
// View controllers will receive this message during segue unwinding. The default implementation returns the result of -respondsToSelector: - controllers can override this to perform any ancillary checks, if necessary.
- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender NS_AVAILABLE_IOS(6_0);

// Custom containers should override this method and search their children for an action handler (using -canPerformUnwindSegueAction:fromViewController:sender:). If a handler is found, the controller should return it. Otherwise, the result of invoking super's implementation should be returned.
- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender NS_AVAILABLE_IOS(6_0);
*/
@end
