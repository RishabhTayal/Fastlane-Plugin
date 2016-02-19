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
#import "CCPProject.h"

@interface Fastlane()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation Fastlane

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
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

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    NSMenuItem *topMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (topMenuItem) {
        [[topMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *fastlaneMenuItem = [[NSMenuItem alloc] initWithTitle:@"Fastlane" action:nil keyEquivalent:@""];
        [fastlaneMenuItem setTarget:self];
        fastlaneMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"Fastlane"];
        
        NSMenuItem* addLaneMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add/Edit Fastfile" action:@selector(editFastfile) keyEquivalent:@""];
        [addLaneMenuItem setTarget:self];
        [fastlaneMenuItem.submenu addItem:addLaneMenuItem];
        
        NSMenuItem* runFastlane = [[NSMenuItem alloc] initWithTitle:@"Run Fastlane 🚀" action:@selector(runFastlane) keyEquivalent:@""];
        runFastlane.target = self;
        [fastlaneMenuItem.submenu addItem:runFastlane];
        
        [topMenuItem.submenu insertItem:fastlaneMenuItem atIndex:[topMenuItem.submenu indexOfItemWithTitle:@"Build For"]];
    }
}

-(void)editFastfile {
    NSLog(@"add lane");
    CCPProject* project = [CCPProject projectForKeyWindow];
    NSString* fastfilePath = project.fastfilePath;
    
    if (![project hasFastfile]) {
        NSError* error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:[self.bundle pathForResource:@"DefaultPodfile" ofType:@""] toPath:fastfilePath error:&error];
        if (error) {
            [[NSAlert alertWithError:error] runModal];
        }
    }
    
    [[[NSApplication sharedApplication] delegate] application:[NSApplication sharedApplication]
                                                     openFile:fastfilePath];
}

- (void)runFastlane {
    //TODO: Use the paths array and check at which path `fastlane` is installed.
    NSArray* fastlanePaths = @[@"/usr/bin/fastlane", @"/usr/local/bin/fastlane"];
    for (NSString* path in fastlanePaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [CCPShellRunner runShellCommand: path withArgs:@[@"deploy"] directory:[CCPWorkspaceManager currentWorkspaceDirectoryPath] completion:^(NSTask *t) {
                NSLog(@"%@", t);
            }];
            return;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
