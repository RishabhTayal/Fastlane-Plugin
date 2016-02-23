//
//  FLShellRunner.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/18/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "FLShellRunner.h"

@interface FLShellRunner()

@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSPipe* inputPipe;

@end

@implementation FLShellRunner

-(void)runScriptPath:(NSString*)path arguments:(NSArray*)arguments completion:(completion)completion {
    NSLog(@"Running: %@", path);
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        @try {
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments  = arguments;
            
            // Output Handling
            self.outputPipe               = [[NSPipe alloc] init];
            self.buildTask.standardOutput = self.outputPipe;
            
            self.inputPipe = [[NSPipe alloc] init];
            self.buildTask.standardInput = self.inputPipe;
            
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                
                NSData *output = [[self.outputPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                
                NSLog(@"%@", outStr);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(output);
                    }
                });
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            [self.buildTask launch];
            
            [self.buildTask waitUntilExit];
        }
        @catch (NSException *exception) {
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        @finally {
            
        }
    });
}

-(void)addUserInput:(NSString*)userInput {
    [self.inputPipe.fileHandleForWriting writeData:[userInput dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
