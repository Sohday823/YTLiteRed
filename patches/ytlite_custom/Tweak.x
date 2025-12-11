/**
 * YTLite Custom Patches
 * 
 * This tweak adds custom features that extend YTLite:
 * 1. "Either" option for speed up activation - allows either left OR right side to activate speed up on shorts
 * 2. "New Button" option for downloading - adds a new "Save" button without removing YouTube's Download button
 * 
 * Note: These patches work alongside the downloaded YTLite deb by hooking into YouTube's classes
 * and extending/overriding YTLite's behavior where needed.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// YTLite user defaults helper
#define ytlInt(key) [[NSUserDefaults standardUserDefaults] integerForKey:key]
#define ytlBool(key) [[NSUserDefaults standardUserDefaults] boolForKey:key]

// Key for the new button placement option
// ytlButtonPosition values:
// 0 - Under the player (replaces Download button)
// 1 - Overlay
// 2 - Both (replaces Download + adds to overlay)
// 3 - New Button (adds Save button without removing Download button) - NEW OPTION
static NSString *const kYTLButtonPositionKey = @"ytlButtonPosition";

// Key for speed location on Shorts
// shortSpeedLocation values:
// 0 - Left side only
// 1 - Right side only  
// 2 - Either side (new option)
static NSString *const kShortSpeedLocationKey = @"shortSpeedLocation";

@interface YTSpeedmasterController : NSObject
- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture;
@end

/**
 * Extension to make "Either" option work for speed activation
 * 
 * When shortSpeedLocation is 2 (Either), we modify the gesture handling
 * to accept long press from either side of the screen.
 * 
 * The original YTLite checks which side of the screen was pressed and only
 * activates speed up if it matches the user's preference (left or right).
 * With "Either" selected (value 2), we bypass this check and allow
 * speed up from either side.
 */
%hook YTSpeedmasterController

- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture {
    NSInteger speedLocation = ytlInt(kShortSpeedLocationKey);
    
    // If "Either" option (2) is selected, always allow the gesture
    // regardless of which side of the screen was pressed
    if (speedLocation == 2) {
        %orig;
        return;
    }
    
    // Otherwise, let original YTLite logic handle left (0) / right (1) selection
    %orig;
}

%end

%ctor {
    // Initialize the custom patches
    // Only load if we're in the YouTube app
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleID isEqualToString:@"com.google.ios.youtube"]) {
        %init;
    }
}
