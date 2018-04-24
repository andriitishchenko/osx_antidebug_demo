//
//  ViewController.h
//  AntiDebugDemo
//
//  Created by Andrii Tishchenko on 4/24/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (unsafe_unretained) IBOutlet NSTextView *txtLog;
//-(void)checkDebug;


@end

