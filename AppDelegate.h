#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *_window;
    unsigned char *_imageData;
    bool _imageDataAllocated;
    NSImageView *_imageView;
    NSTimer *mouseStateTimer;
}
- (void)openImageFromMenu;
@end
