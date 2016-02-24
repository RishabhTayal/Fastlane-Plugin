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
@property (nonatomic, weak) IBOutlet NSPopUpButton* popUpButton3;
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
    
    [self loadEnvironments];
}

- (IBAction)runFastlane:(NSButton *)sender {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps) {
        if([app.bundleIdentifier.lowercaseString isEqualToString:@"com.apple.terminal"]) {
            [app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
            break;
        }
    }
    
    NSString* script = [NSString stringWithFormat:@"tell app \"Terminal\" \n do script activate \n delay 1 \n do script \"cd %@\" in window 1 \n do script \"fastlane %@ %@", _workspacePath,self.popUpButton1.titleOfSelectedItem, self.popUpButton2.titleOfSelectedItem];
    
    if (self.popUpButton3.stringValue.length > 0) {
        script = [script stringByAppendingString:[NSString stringWithFormat:@" --env %@", self.popUpButton3.titleOfSelectedItem]];
    }
    
    script = [script stringByAppendingString:@"\" in window 1 \n end tell"];
    
    FLShellRunner* runner = [[FLShellRunner alloc] init];
    [runner runScriptPath:@"/usr/bin/osascript" arguments:@[@"-e", script] withDirectoryPath:_workspacePath completion:^(NSData *data) {
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

-(void)loadEnvironments {
    NSArray* dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/fastlane", _workspacePath] error:nil];
    NSLog(@"%@", dirFiles);
    NSArray* envFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH %@", @".env"]];
    NSLog(@"%@", envFiles);
    NSMutableArray* enviornments = [NSMutableArray new];
    for (NSString* env in envFiles) {
        NSRange range = [env rangeOfString:@".env"];
        [enviornments addObject:[env stringByReplacingCharactersInRange:range withString:@""]];
    }
    
    [self.popUpButton3 removeAllItems];
    [self.popUpButton3 addItemsWithTitles:enviornments];
}

@end
