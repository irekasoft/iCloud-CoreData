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

    [IRCoreDataController new];
    
    [self checkForiCloud];
    
    self.iCloudKeyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    
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
    //
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *ubiquityURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        if (ubiquityURL == nil)
        {
            // display the alert from the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iCloud Not Configured"
                                                                    message:@"Open iCloud Settings, and make sure you are logged in."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
                
                self.lbl_icloud_status.text = @"iCloud is not avalaible";
                
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lbl_icloud_status.text = @"iCloud is avalaible";
            });
            
        }
        
        
    });
}

@end
