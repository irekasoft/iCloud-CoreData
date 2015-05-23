//
//  ViewController.h
//  CoreData_iCloud
//
//  Created by Hijazi on 21/2/15.
//  Copyright (c) 2015 iReka Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistentStack.h"
#import "Event.h"

#define ICLOUD_ONLY YES
#define K_PROFILE @"profile_key"
#define K_ENABLE_ICLOUD @"enable_icloud_key"
#define DEFAULTS [NSUserDefaults standardUserDefaults]

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) PersistentStack* persistentStack;

@property (strong) NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sc_profile;

@property (strong) NSUbiquitousKeyValueStore *iCloudKeyValueStore;
@property (weak, nonatomic) IBOutlet UISwitch *switch_enable_iCloud;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

