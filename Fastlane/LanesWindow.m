//
//  LanesWindow.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/22/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import "LanesWindow.h"
#import "FLShellRunner.h"
#import "FLProject.h"
#import "FLWorkspaceManager.h"

@interface LanesWindow ()

@property (nonatomic, weak) IBOutlet NSPopUpButton* popUpButton1;
@property (nonatomic, weak) IBOutlet NSPopUpButton* popUpButton2;
@property (nonatomic, weak) IBOutlet NSTextField* laneDescTextField;
@property (nonatomic, weak) IBOutlet NSButton* fastlaneButton;

@end

@implementation LanesWindow

-(instancetype)init {
    self = [super initWithWindowNibName:NSStringFromClass(self.class)];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.popUpButton1.target = self;
    self.popUpButton2.target = self;
    self.popUpButton1.autoenablesItems = false;
    
    [self.popUpButton1 removeAllItems];
    [self.popUpButton2 removeAllItems];
    [self.popUpButton1 addItemsWithTitles:_lanesData.allKeys];
    
    [self popup1Changed:self.popUpButton1];
    
    self.fastlaneButton.target = self;
    [self.fastlaneButton setAction:@selector(runFastlane:)];
}

- (IBAction)runFastlane:(NSButton *)sender {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps) {
        if([app.bundleIdentifier.lowercaseString isEqualToString:@"com.apple.terminal"]) {
            [app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
            break;
        }
    }
    
    FLShellRunner* runner = [[FLShellRunner alloc] init];
    [runner runScriptPath:@"/usr/bin/osascript" arguments:@[@"-e", [NSString stringWithFormat:@"tell app \"Terminal\" \n do script activate \n delay 1 \n do script \"cd %@\" in window 1 \n do script \"fastlane %@ %@\" in window 1 \n end tell", _workspacePath,self.popUpButton1.titleOfSelectedItem, self.popUpButton2.titleOfSelectedItem]] withDirectoryPath:_workspacePath completion:^(NSData *data) {
    }];
}

-(IBAction)popup1Changed:(id)sender {
    NSString* selectedType = self.popUpButton1.titleOfSelectedItem;
    NSDictionary* lanes = _lanesData[selectedType];

    [self.popUpButton2 removeAllItems];
    for (id lane in lanes.allKeys) {
        NSLog(@"%@", lane);
        [self.popUpButton2 addItemWithTitle:lane];
    }
    
    [self popup2Changed:self.popUpButton2];
}

- (IBAction)popup2Changed:(id)sender {
    NSString* selectedPlatform = self.popUpButton1.titleOfSelectedItem;
    NSDictionary* lanes = _lanesData[selectedPlatform];
    for (id lane in lanes.allKeys) {
        if (lane == self.popUpButton2.titleOfSelectedItem) {
            self.laneDescTextField.stringValue = lanes[lane][@"description"];
            return;
        }
    }
}

@end
