//
//  ViewController.m
//  CoreData_iCloud
//
//  Created by Hijazi on 21/2/15.
//  Copyright (c) 2015 iReka Soft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbl_icloud_status;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self checkForiCloud];

    //
    // icloud key-value store
    // suitable for settings
    // or simple data persistent througout app ecosystem.
    //
    // but we want user to use
    // wheater want icloud or not.
    
    self.iCloudKeyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    [self.iCloudKeyValueStore synchronize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStoreChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.iCloudKeyValueStore];
    
    
    
    [self updateUI];
    
    [self refreshCoreData];
}
- (NSURL*)storeURL
{
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"Model.sqlite"];
}
- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
}
- (void)refreshCoreData{
    // Configure interface objects here.
    
    
    self.persistentStack = [[PersistentStack alloc] initWithStoreURL:self.storeURL modelURL:self.modelURL];
    self.managedObjectContext = self.persistentStack.managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    
    self.dataArray = @[@"sample", @"array"];
    
    NSMutableArray *tempArray = [NSMutableArray array];

    for (Event *event in result) {
        NSLog(@"%@", event.timeStamp);
        [tempArray addObject:[event.timeStamp description]];
    }
    self.dataArray = tempArray;
    
    
    [self.tableView reloadData];
    
}

- (void)updateUI{
    
    NSInteger selectedIdx;
    
    if (ICLOUD_ONLY) {
        
        selectedIdx = (NSInteger)[self.iCloudKeyValueStore doubleForKey:K_PROFILE];
        NSLog(@"sel %ld", selectedIdx);
        
    }else{
        
        if ([self.iCloudKeyValueStore objectForKey:K_PROFILE] != nil) {
    
            NSLog(@"have");
    
            selectedIdx = [self.iCloudKeyValueStore doubleForKey:K_PROFILE];
    
            // override the default
            [DEFAULTS setInteger:selectedIdx forKey:K_PROFILE];
            [DEFAULTS synchronize];
    
    
        }else{
    
            NSLog(@"have not");
    
            selectedIdx = [DEFAULTS integerForKey:K_PROFILE];
            
        }
        
    }
    
    self.sc_profile.selectedSegmentIndex = selectedIdx;
    
}

- (void)updateSettings{
    
    
    
}

#pragma mark -

- (IBAction)sc_changed:(UISegmentedControl *)sender {
    
    // save locally
    [DEFAULTS setInteger:sender.selectedSegmentIndex forKey:K_PROFILE];
    [DEFAULTS synchronize];
    
    
    // save to icloud
    [self.iCloudKeyValueStore setDouble:sender.selectedSegmentIndex forKey:K_PROFILE];
    [self.iCloudKeyValueStore synchronize];
    
    // check
    NSLog(@"sel %f", [self.iCloudKeyValueStore doubleForKey:K_PROFILE]);
}

#pragma mark 

- (void)handleStoreChange:(NSNotification *)notification{
    
    NSLog(@" notif %@" ,notification);
    [self updateUI];
    
}

- (IBAction)open:(id)sender {

    NSLog(@"%@",UIApplicationOpenSettingsURLString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkForiCloud
{
    // obtaining the URL for our ubiquity container could potentially take a long time,
    // so dispatch this call so to not block the main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *ubiquityURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        if (ubiquityURL == nil)
        {
            // display the alert from the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.lbl_icloud_status.text = @"iCloud is not avalaible";
                
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lbl_icloud_status.text = @"iCloud is avalaible";
                self.switch_enable_iCloud.enabled = YES;
            });
            
        }
        
        
    });
}

- (void)display_iCloudAlert{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iCloud Not Configured"
                                                        message:@"Open iCloud Settings, and make sure you are logged in."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    
    
}

- (IBAction)switch_change:(UISwitch *)sender {
    
    
    if (sender.isOn == YES){
        
        
        
    }else if (sender.isOn == NO){
        
        
        
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.textLabel.text = self.dataArray[indexPath.row];
}

- (IBAction)addItem:(id)sender {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }else{
        [self refreshCoreData];
    }
}

@end
