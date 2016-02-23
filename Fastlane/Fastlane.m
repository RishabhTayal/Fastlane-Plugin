//
//  Fastlane.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/18/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import "Fastlane.h"
#import "FLShellRunner.h"
#import "FLWorkspaceManager.h"
#import "FLProject.h"
#import "LanesWindow.h"

@interface Fastlane()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (nonatomic, strong) NSMenuItem* fastlaneMenuItem;
@property (nonatomic, strong) NSMenuItem* addEditFastlaneMenuItem;

@property (nonatomic, strong) LanesWindow* lanesWindow;

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
    
    //    [self setFastlanePath];
    
    // Create menu items, initialize UI, etc.
    NSMenuItem *topMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (topMenuItem) {
        
        [[topMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        _fastlaneMenuItem = [[NSMenuItem alloc] initWithTitle:@"Fastlane" action:nil keyEquivalent:@""];
        [_fastlaneMenuItem setTarget:self];
        _fastlaneMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"Fastlane"];
        
        self.addEditFastlaneMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add/Edit Fastfile" action:@selector(editFastfile) keyEquivalent:@""];
        [self.addEditFastlaneMenuItem setTarget:self];
        [_fastlaneMenuItem.submenu addItem:self.addEditFastlaneMenuItem];
        
        NSMenuItem* runFastlane = [[NSMenuItem alloc] initWithTitle:@"Run Fastlane 🚀" action:@selector(runFastlane) keyEquivalent:@""];
        runFastlane.target = self;
        //        runFastlane.submenu = [[NSMenu alloc] initWithTitle:@"Run Fastlane 🚀"];
        [self addLanesOptionToMenu:runFastlane];
        [_fastlaneMenuItem.submenu addItem:runFastlane];
        
        [_fastlaneMenuItem.submenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* setupFastlane = [[NSMenuItem alloc] initWithTitle:@"Setup Fastlane" action:@selector(setupFastlane) keyEquivalent:@""];
        setupFastlane.target = self;
        [_fastlaneMenuItem.submenu addItem:setupFastlane];
        
        [topMenuItem.submenu insertItem:_fastlaneMenuItem atIndex:[topMenuItem.submenu indexOfItemWithTitle:@"Build For"]];
    }
    
}

-(void)editFastfile {
    NSLog(@"add lane");
    FLProject* project = [FLProject projectForKeyWindow];
    NSString* fastfilePath = project.fastfilePath;
    
    if (![project hasFastfile]) {
        NSError* error = nil;
        //        [[NSFileManager defaultManager] copyItemAtPath:[self.bundle pathForResource:@"DefaultPodfile" ofType:@""] toPath:fastfilePath error:&error];
        //        if (error) {
        //            [[NSAlert alertWithError:error] runModal];
        //        }
    }
    
    [[[NSApplication sharedApplication] delegate] application:[NSApplication sharedApplication]
                                                     openFile:fastfilePath];
}

//-(BOOL)validateMenuItem:(NSMenuItem *)menuItem {
//    NSLog(@"validating");
//    if ([menuItem isEqual:self.addEditFastlaneMenuItem]) {
//        NSLog(@"%@", [FLWorkspaceManager currentWorkspaceDirectoryPath]);
//        FLProject* project = [[FLProject alloc] init];
//        [FLShellRunner runShellCommand:[project fastlanePath] withArgs:@[@"lanes"] directory:[FLWorkspaceManager currentWorkspaceDirectoryPath] completion:^(NSTask *t) {
//            NSLog(@"%@", [t standardOutput]);
//            NSPipe* outPipe = t.standardOutput;
//            NSFileHandle* read = [outPipe fileHandleForReading];
//            NSData* dataRead = read.readDataToEndOfFile;
//            NSLog(@"%@", [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding]);
//        }];
//    }
//    return true;
//}

-(void)addLanesOptionToMenu:(NSMenuItem*)menu {
    //    [FLShellRunner runShellCommand:[project fastlanePath] withArgs:@[@"lanes"] directory:[FLWorkspaceManager currentWorkspaceDirectoryPath] completion:^(NSTask *t) {
    //        NSLog(@"%@", t.standardOutput);
    //    }];
}

- (void)runFastlane {
    //    [FLShellRunner runShellCommand: [[FLProject projectForKeyWindow] fastlanePath] withArgs:@[@"deploy"] directory:[FLWorkspaceManager currentWorkspaceDirectoryPath] completion:^(NSTask *t) {
    //        NSLog(@"%@", t);
    //    }];
    
    FLShellRunner* shellRunner = [[FLShellRunner alloc] init];
    NSString* path = [NSString stringWithFormat:@"%@/Desktop/Personal/fastlane/bin/fastlane", NSHomeDirectory()];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* data = [shellRunner runScriptPath:path arguments:@[@"lanes", @"--json"] withDirectoryPath:[FLWorkspaceManager currentWorkspaceDirectoryPath]];
        NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString* jsonString = [string substringWithRange:NSMakeRange([string rangeOfString:@"{"].location, string.length - [string rangeOfString:@"{"].location)];
        NSLog(@"JSON: %@", [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]);
        id lanesJson = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            _lanesWindow = [LanesWindow new];
            _lanesWindow.lanesData = lanesJson;
            _lanesWindow.workspacePath = [FLWorkspaceManager currentWorkspaceDirectoryPath];
            [[NSApp keyWindow] beginSheet:_lanesWindow.window completionHandler:nil];
        });
    });
}

-(void)setupFastlane {
    FLShellRunner* runner = [[FLShellRunner alloc] init];
    
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps) {
        if([app.bundleIdentifier.lowercaseString isEqualToString:@"com.apple.terminal"]) {
            [app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
            break;
        }
    }
    
    [runner runScriptPath:@"/usr/bin/osascript" arguments:@[@"-e", @"tell app \"Terminal\" to do script \"fastlane init\""] withDirectoryPath:[FLWorkspaceManager currentWorkspaceDirectoryPath] completion:^(NSData *data) {
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
