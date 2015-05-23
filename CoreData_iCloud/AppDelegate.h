//
//  AppDelegate.h
//  CoreData_iCloud
//
//  Created by Hijazi on 21/2/15.
//  Copyright (c) 2015 iReka Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistentStack.h"
#import "IRCoreDataController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) IRCoreDataController *coreDataController;

@end

