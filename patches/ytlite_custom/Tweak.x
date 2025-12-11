/**
 * YTLite Custom Patches
 * 
 * This tweak provides supporting infrastructure for custom YTLite features.
 * 
 * Features:
 * 1. "Either" option for speed up activation
 *    - The localization strings for this option are injected into YTLite's bundle
 *    - The actual behavioral logic requires YTLite to read the shortSpeedLocation setting
 *      and handle value 2 (Either) to accept gestures from both sides
 *    - This tweak serves as a placeholder for future implementation when YTLite source is available
 * 
 * 2. "New Button" option for downloading
 *    - Localization strings are added for this option
 *    - Full implementation requires YTLite source modification
 * 
 * Note: These patches work alongside the downloaded YTLite deb. The localization
 * changes are injected during the build process in main.yml.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// YTLite user defaults helper
#define ytlInt(key) [[NSUserDefaults standardUserDefaults] integerForKey:key]

// Key for speed location on Shorts
// shortSpeedLocation values:
// 0 - Left side only  
// 1 - Right side only  
// 2 - Either side (new option added by this fork)
static NSString *const kShortSpeedLocationKey = @"shortSpeedLocation";

@interface YTSpeedmasterController : NSObject
- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture;
@end

/**
 * Hook for "Either" speed location option
 * 
 * This hook intercepts the speed control gesture handler.
 * When shortSpeedLocation is 2 (Either), the gesture should be accepted
 * regardless of which side of the screen was pressed.
 * 
 * Implementation note: The actual left/right detection logic is in YTLite's
 * compiled code. This hook passes through to the original implementation.
 * For the "Either" option to work fully, YTLite would need to check for
 * value 2 and bypass its left/right checks.
 */
%hook YTSpeedmasterController

- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture {
    // Note: The "Either" option (value 2) requires YTLite to support it.
    // This hook ensures the gesture is always passed to YTLite.
    // The localization strings for "Either" are injected separately.
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
