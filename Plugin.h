//
//  Plugin.h
//  XCodePlugin
//
//  Created by Greg Fodor on 1/13/15.
//
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface Plugin : NSObject

- (BOOL)moveWindowToRift;

@end


BOOL MoveWindowToRift() {
    return [[[Plugin alloc] init] moveWindowToRift];
}