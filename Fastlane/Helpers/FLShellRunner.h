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

-(void)runScriptPath:(NSString*)path arguments:(NSArray*)arguments completion:(completion)completion;
-(void)addUserInput:(NSString*)userInput;

@end
