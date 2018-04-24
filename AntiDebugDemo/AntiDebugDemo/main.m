//
//  main.m
//  AntiDebugDemo
//
//  Created by Andrii Tishchenko on 4/24/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "NSObject+AntiDebuger.h"

int main(int argc, const char * argv[]) {
  printf("%s","s");
  return NSApplicationMain(argc, argv);
}
