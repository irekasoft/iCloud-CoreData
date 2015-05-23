//
//  IRManager.m
//  CoreData_iCloud
//
//  Created by Hijazi on 21/2/15.
//  Copyright (c) 2015 iReka Soft. All rights reserved.
//

#import "IRCoreDataController.h"

NSString * kiCloudPersistentStoreFilename = @"iCloudStore.sqlite";

NSString * kSeedStoreFilename = @"seedStore.sqlite"; //holds the seed person records
NSString * kLocalStoreFilename = @"localStore.sqlite"; //holds the states information

@interface IRCoreDataController (private)

@property (nonatomic, strong) NSURL *ubiquityURL;

@end


@implementation IRCoreDataController
{
    NSLock *_loadingLock;
    NSURL *_presentedItemURL;
}

- (id)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    id currentToken = [fileManager ubiquityIdentityToken];
    BOOL is_iCloudSignedIn = (currentToken != nil);
    
    NSLog(@"icloud is signed on: %d %@",is_iCloudSignedIn, currentToken);
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainThreadContext setPersistentStoreCoordinator:_psc];
    _currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    [self subsribeNotifications];
    
    
    return self;
}

- (void)subsribeNotifications{

    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
                                             selector:@selector(storeWillChange:)
                                                 name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                               object:nil];

    [dc addObserver:self selector:@selector(storeDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
    
    

}

- (void)storeWillChange:(NSNotification *)n{
    
}
- (void)storeDidChange:(NSNotification *)n{
    
}

#pragma mark Managing the Persistent Stores
- (void)loadPersistentStores {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        BOOL locked = NO;
        @try {
            [_loadingLock lock];
            locked = YES;
            [self asyncLoadPersistentStores];
        } @finally {
            if (locked) {
                [_loadingLock unlock];
                locked = NO;
            }
        }
    });
}
- (void)asyncLoadPersistentStores{
    
    BOOL success = YES;
    NSError *localError = nil;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    _ubiquityURL = [fm URLForUbiquityContainerIdentifier:nil];
    
    
    NSURL *iCloudDataURL = [self.ubiquityURL URLByAppendingPathComponent:@"iCloudData"];
    
    NSDictionary *options = @{ NSPersistentStoreUbiquitousContentNameKey : @"iCloudStore",
                               NSPersistentStoreRebuildFromUbiquitousContentOption : @YES};
    
    
    _iCloudStore = [self.psc addPersistentStoreWithType:NSSQLiteStoreType
                                          configuration:@"CloudConfig"
                                                    URL:iCloudDataURL
                                                options:options
                                                  error:&localError];
    success = (_iCloudStore != nil);
    if (success) {
        //set up the file presenter
        _presentedItemURL = iCloudDataURL;
        [NSFileCoordinator addFilePresenter:self];
    } else {
        
    }
    
}

- (void)iCloudAccountChanged:(NSNotification *)notification {
    
    // update the current ubiquity token
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    _currentUbiquityToken = token;
    
    //reload persistent store
    [self loadPersistentStores];
}

static NSOperationQueue *_presentedItemOperationQueue;

- (NSURL *)presentedItemURL {
    return _presentedItemURL;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return _presentedItemOperationQueue;
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self iCloudAccountChanged:nil];
    });
    completionHandler(NULL);
}

@end
