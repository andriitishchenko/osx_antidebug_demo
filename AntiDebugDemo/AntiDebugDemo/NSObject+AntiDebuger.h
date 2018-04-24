//
//  NSObject+AntiDebuger.h
//  AntiDebugDemo
//
//  Created by Andrii Tishchenko on 4/24/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
bool AmIBeingDebugged(void);

@interface NSObject (AntiDebuger)

@end
