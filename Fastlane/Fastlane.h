//
//  Fastlane.h
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/18/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Fastlane;

static Fastlane *sharedPlugin;

@interface Fastlane : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end