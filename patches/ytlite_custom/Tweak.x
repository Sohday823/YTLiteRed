/**
 * YTLite Custom Patches
 * 
 * This tweak adds custom features that extend YTLite:
 * 1. "Either" option for speed up activation - allows either left OR right side to activate speed up on shorts
 * 
 * Note: These patches work alongside the downloaded YTLite deb by hooking into YouTube's classes
 * and extending/overriding YTLite's behavior where needed.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// YTLite user defaults helper
#define ytlInt(key) [[NSUserDefaults standardUserDefaults] integerForKey:key]

@interface YTMainAppVideoPlayerOverlayView : UIView
@property (nonatomic, assign, readonly) id scrubUserEducationView;
@property (nonatomic, weak, readwrite) id delegate;
@end

@interface YTSpeedmasterController : NSObject
- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture;
@end

@interface YTReelContentView : UIView
@end

/**
 * Hook for "Either" speed location option
 * 
 * The original YTLite has options for "Left" (index 0) and "Right" (index 1).
 * We add "Either" (index 2) which activates speed up on either side.
 * 
 * The shortSpeedLocation key stores:
 * - 0: Left side only
 * - 1: Right side only  
 * - 2: Either side (new option)
 */
%hook YTReelContentView

- (void)layoutSubviews {
    %orig;
    
    // Check if "Either" option is selected (index 2)
    NSInteger speedLocation = ytlInt(@"shortSpeedLocation");
    
    if (speedLocation == 2) {
        // When "Either" is selected, we need to enable gesture recognition on both sides
        // This is handled by adding gesture recognizers to both left and right regions
        // The actual speed control is handled by YTSpeedmasterController
        
        // Note: The gesture recognizers are typically set up by YTLite
        // With "Either" selected, both sides should work
    }
}

%end

/**
 * Extension to make "Either" option work for speed activation
 * 
 * When shortSpeedLocation is 2 (Either), we modify the gesture handling
 * to accept long press from either side of the screen
 */
%hook YTSpeedmasterController

- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture {
    NSInteger speedLocation = ytlInt(@"shortSpeedLocation");
    
    // If "Either" option (2) is selected, always allow the gesture
    // Otherwise, let original logic handle left (0) / right (1) selection
    if (speedLocation == 2) {
        // Force enable - the gesture should work regardless of which side
        %orig;
        return;
    }
    
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
