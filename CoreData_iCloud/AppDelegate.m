//
//  AppDelegate.m
//  CoreData_iCloud
//
//  Created by Hijazi on 21/2/15.
//  Copyright (c) 2015 iReka Soft. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) PersistentStack* persistentStack;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _coreDataController = [[IRCoreDataController alloc] init];
    [_coreDataController loadPersistentStores];
    
    return YES;
}




@end
