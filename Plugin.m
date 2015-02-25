#import "Plugin.h"
#import <IOKit/graphics/IOGraphicsLib.h>

static void KeyArrayCallback(const void* key, const void* value, void* context) { CFArrayAppendValue(context, key);  }

@implementation Plugin

- (BOOL)moveWindowToRift {
    __block bool sentToRift = NO;
    
    if ([NSScreen screens].count > 0) {
        [[NSScreen screens] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id screen, NSUInteger idx, BOOL *stop) {
            NSRect riftFrame = ((NSScreen *)screen).visibleFrame;
            
            // Find the rift by looking up the local name of the devices.
            NSDictionary* screenDictionary = [screen deviceDescription];
            NSNumber* screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
            CGDirectDisplayID aID = [screenID unsignedIntValue];
            CFStringRef localName = NULL;
            io_connect_t displayPort = CGDisplayIOServicePort(aID);
            CFDictionaryRef dict = (CFDictionaryRef)IODisplayCreateInfoDictionary(displayPort, 0);
            CFDictionaryRef names = CFDictionaryGetValue(dict, CFSTR(kDisplayProductName));
            if(names)
            {
                CFArrayRef langKeys = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks );
                CFDictionaryApplyFunction(names, KeyArrayCallback, (void*)langKeys);
                CFArrayRef orderLangKeys = CFBundleCopyPreferredLocalizationsFromArray(langKeys);
                CFRelease(langKeys);
                if(orderLangKeys && CFArrayGetCount(orderLangKeys))
                {
                    CFStringRef langKey = CFArrayGetValueAtIndex(orderLangKeys, 0);
                    localName = CFDictionaryGetValue(names, langKey);
                    CFRetain(localName);
                }
                CFRelease(orderLangKeys);
            }
            CFRelease(dict);
            NSString *localNameString = (__bridge NSString *)localName;
            
            if ([localNameString isEqualToString:@"Rift DK2"]) {
                NSWindow *window = [[NSApplication sharedApplication] mainWindow];
                
                // Determine if there is a OS X menu bar on the rift. (This is dependent upon user settings.)
                BOOL riftHasMenuBar = riftFrame.size.height == 1080.0 ? NO : YES;
                CGFloat menuBarHeight = [[NSApplication sharedApplication] mainMenu].menuBarHeight;
                
                // Target frame is screen nudged upwards if there is a menu bar.
                // The height is scaled up slightly larger than necessary, and going full screen corrects the issue.
                NSRect targetFrame = NSMakeRect(riftFrame.origin.x,
                                                riftFrame.origin.y + (riftHasMenuBar ? menuBarHeight : 0.0),
                                                1920.0, 1080.0 + 22.0);
                
                // The following operations needs to happen in this exact order, otherwise you may get
                // a clipped/offset viewport on the rift, or framebuffer flickering/corruption.
                
                // Hide menubars, etc. and move window.
                [NSMenu setMenuBarVisible:NO];
                [window setFrame:targetFrame display: YES];
                [NSMenu setMenuBarVisible:NO];
                
                // Focus window and move cursor to center of rift screen so clicks don't end up de-focusing.
                [window makeKeyWindow];
                [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
                CGWarpMouseCursorPosition(CGPointMake(targetFrame.origin.x + targetFrame.size.width / 2.0f,
                                                      targetFrame.origin.y + targetFrame.size.height / 2.0f));
                sentToRift = YES;
            }
        }];
    }
    
    return sentToRift;
}

@end
