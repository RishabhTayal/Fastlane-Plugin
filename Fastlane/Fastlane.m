//
//  Fastlane.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/18/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import "Fastlane.h"
#import "CCPShellRunner.h"
#import "CCPWorkspaceManager.h"

@interface Fastlane()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation Fastlane

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Fastlane" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    //    NSAlert *alert = [[NSAlert alloc] init];
    //    [alert setMessageText:@"Hello, World"];
    //    [alert runModal];
    NSLog(@"%@", [CCPWorkspaceManager currentWorkspaceDirectoryPath]);
    [CCPShellRunner runShellCommand:@"/usr/bin/fastlane" withArgs:@[@"deploy"] directory:[CCPWorkspaceManager currentWorkspaceDirectoryPath] completion:^(NSTask *t) {
        NSLog(@"%@", t);
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
