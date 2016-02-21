//
//  WindowController.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/20/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()

@end

@implementation WindowController

-(instancetype)init {
    self = [super initWithWindowNibName:NSStringFromClass(self.class)];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
