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

@end

@implementation FLShellRunner

-(void)runScriptPath:(NSString*)path arguments:(NSArray*)arguments withDirectoryPath:(NSString*)directorypath completion:(completion)completion {
    NSLog(@"Running: %@", path);
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        @try {
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments  = arguments;
            self.buildTask.currentDirectoryPath = directorypath;
            
            // Output Handling
            self.outputPipe               = [[NSPipe alloc] init];
            self.buildTask.standardOutput = self.outputPipe;
            
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

-(NSData*)runScriptPath:(NSString *)path arguments:(NSArray *)arguments withDirectoryPath:(NSString *)directorypath {
    self.buildTask = [[NSTask alloc] init];
    
    self.buildTask.launchPath = path;
    self.buildTask.arguments = arguments;
    self.buildTask.currentDirectoryPath = directorypath;
    
    self.outputPipe = [NSPipe pipe];
    [self.buildTask setStandardOutput:self.outputPipe];
    [self.buildTask setStandardError:self.outputPipe];
    NSFileHandle *readHandle = [self.outputPipe fileHandleForReading];
    
    [self.buildTask launch];
    [self.buildTask waitUntilExit];
    
    NSData *outputData = [readHandle readDataToEndOfFile];
    //    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    return outputData;
}

@end
