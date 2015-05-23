//
//  IRManager.h
//  CoreData_iCloud
//
//  Created by Hijazi on 21/2/15.
//  Copyright (c) 2015 iReka Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
/*

 to enable icloud manager please go on to capabilities and turn on icloud.
 
*/

@interface IRCoreDataController : NSObject <NSFilePresenter>

@property (nonatomic, readonly) NSPersistentStoreCoordinator *psc;
@property (nonatomic, readonly) NSManagedObjectContext *mainThreadContext;
@property (nonatomic, readonly) NSPersistentStore *iCloudStore;
@property (nonatomic, readonly) NSPersistentStore *localStore;

@property (nonatomic, readonly) NSURL *ubiquityURL;
@property (nonatomic, readonly) id currentUbiquityToken;

- (void)loadPersistentStores;

@end
