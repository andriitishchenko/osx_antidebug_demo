//
//  ViewController.m
//  AntiDebugDemo
//
//  Created by Andrii Tishchenko on 4/24/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+AntiDebuger.h"

@implementation ViewController


-(void)checkDebug:(NSTimer*)t{
  bool isDebug = AmIBeingDebugged();
  if(isDebug)
    printf("%s \n","CONNECTED");
}

-(void)appendString:(NSString*)str{
  [_txtLog setString: [NSString stringWithFormat:@"%@\n%@",[_txtLog string],str]];
}

-(void)mySecureFunction {
  NSLog(@"mySecureFunction");
  printf("%s \n", __func__);
  NSProcessInfo *processInfo = [NSProcessInfo processInfo];
  int pid = [processInfo processIdentifier];
  NSString *processName = [processInfo processName];
  printf("Process ID is : %d \n", pid);
  printf("Process NAME is : %s \n", [processName UTF8String]);
  
  [self appendString: [@"Process ID: " stringByAppendingString: @(pid).stringValue] ];
  [self appendString: [@"Process NAME: " stringByAppendingString: processName ]];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self mySecureFunction];
  
  [NSTimer scheduledTimerWithTimeInterval:1.0
                                   target:self
                                 selector:@selector(checkDebug:)
                                 userInfo:nil
                                  repeats:YES];

  // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}


@end
