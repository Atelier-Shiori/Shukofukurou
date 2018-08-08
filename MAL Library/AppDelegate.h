//
//  AppDelegate.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import "MainWindow.h"
#import "MSWeakTimer.h"
#import "MainWindow.h"
#import "messageswindow.h"
#import "ListStatistics.h"

#ifdef defined(AppStore)
#else
#import <Patreon/Patreon.h>
#endif

@class ProfileWindowController;
@class servicemenucontroller;
@class ListImport;
@class ListExporter;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong,getter=getMainWindowController) MainWindow *mainwindowcontroller;
@property (strong) NSWindowController *_preferencesWindowController;
@property (strong) messageswindow *messageswindow;
@property (strong) ListStatistics *liststatswindow;
@property (strong) ProfileWindowController *pwc;

// Menus
@property (strong) IBOutlet NSMenuItem *messagesmenuitem;
@property (strong) IBOutlet NSMenuItem *importkitsumenu;
@property (strong) IBOutlet servicemenucontroller* servicemenucontrol;
@property (strong) IBOutlet NSMenuItem *importanilist;

// Preference Window
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

// List Import/Export
@property (strong) IBOutlet ListImport *ListImporterController;
@property (strong) IBOutlet ListExporter *ListExporterController;

// Patreon
#if defined(AppStore)
#else
@property (strong) PatreonManager *pamanager;
#endif

// Core Data
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (IBAction)showpreferences:(id)sender;
- (void)showloginnotice;
- (void)showloginpref;
- (void)clearMessages;
- (messageswindow *)getMessagesWindow;
- (ProfileWindowController *)getProfileWindow;
- (IBAction)unlockprofeatures:(id)sender;
@end
