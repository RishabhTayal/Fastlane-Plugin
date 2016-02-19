//
//  CCPShellHandler.m
//
//  Copyright (c) 2013 Delisa Mason. http://delisa.me
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import <AppKit/AppKit.h>
#import "FLShellRunner.h"
#import "FLRunOperation.h"

@implementation FLShellRunner

+ (void)runShellCommand:(NSString*)command withArgs:(NSArray*)args directory:(NSString*)directory completion:(void (^)(NSTask* t))completion
{
    static NSOperationQueue* operationQueue;
    if (operationQueue == nil) {
        operationQueue = [NSOperationQueue new];
    }
    
    NSTask* task = [NSTask new];
    
    //    NSMutableDictionary* environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    //    environment[@"LC_ALL"] = @"en_US.UTF-8";
    //    environment[@"COCOAPODS_DISABLE_STATS"] = @"1";
    //    [task setEnvironment:environment];
    
    task.currentDirectoryPath = directory;
    task.launchPath = command;
    task.arguments = args;
    
    FLRunOperation* operation = [[FLRunOperation alloc] initWithTask:task];
    operation.completionBlock = ^{
        if (completion)
            completion(task);
    };
    [operationQueue addOperation:operation];
}

@end
