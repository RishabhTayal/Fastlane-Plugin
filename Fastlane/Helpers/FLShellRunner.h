//
//  FLShellRunner.h
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/18/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLShellRunner : NSObject

typedef void(^completion)(NSData* data);

-(void)runScriptPath:(NSString*)path arguments:(NSArray*)arguments withDirectoryPath:(NSString*)directorypath completion:(completion)completion;
-(NSData*)runScriptPath:(NSString *)path arguments:(NSArray *)arguments withDirectoryPath:(NSString *)directorypath;
-(void)addUserInput:(NSString*)userInput;

@end
