//
//  CCPWorkspace.m
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

#import <objc/runtime.h>

#import "FLProject.h"
#import "FLWorkspaceManager.h"

@implementation FLProject

+ (instancetype)projectForKeyWindow
{
    id workspace = [FLWorkspaceManager workspaceForKeyWindow];
    
    id contextManager = [workspace valueForKey:@"_runContextManager"];
    for (id scheme in [contextManager valueForKey:@"runContexts"]) {
        NSString* schemeName = [scheme valueForKey:@"name"];
        if (![schemeName hasPrefix:@"Pods-"]) {
            NSString* path = [FLWorkspaceManager directoryPathForWorkspace:workspace];
            return [[FLProject alloc] initWithName:schemeName path:path];
        }
    }
    
    return nil;
}

- (id)initWithName:(NSString*)name path:(NSString*)path
{
    if (self = [self init]) {
        _projectName = name;
        _directoryPath = path;
        
        NSString* infoPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@-Info.plist", _projectName, _projectName]];
        
        _infoDictionary = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        _fastfilePath = [path stringByAppendingPathComponent:@"fastlane/Fastfile"];
    }
    
    return self;
}

-(NSString*)fastlanePath {
    //TODO: Use the paths array and check at which path `fastlane` is installed.
    NSArray* fastlanePaths = @[@"/usr/bin/fastlane", @"/usr/local/bin/fastlane"];
    for (NSString* path in fastlanePaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return path;
        }
    }
    return @"";
}

- (NSString*)workspacePath
{
    return [NSString stringWithFormat:@"%@/%@.xcworkspace", self.directoryPath, self.projectName];
}

- (BOOL)hasFastfile
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.fastfilePath];
}

- (BOOL)containsFileWithName:(NSString*)fileName
{
    NSString* filePath = [self.directoryPath stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

@end
