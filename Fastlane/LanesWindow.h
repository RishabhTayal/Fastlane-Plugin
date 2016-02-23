//
//  LanesWindow.h
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/22/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LanesWindow : NSWindowController

@property (nonatomic, strong) NSDictionary* lanesData;
@property (nonatomic, strong) NSString* workspacePath;

@end
