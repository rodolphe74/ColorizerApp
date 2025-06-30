#!/bin/bash

APP_NAME="Colorizer"
# mkdir -p $APP_NAME && cd $APP_NAME

# Création des fichiers source
cat > main.mm << 'EOF'
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        return NSApplicationMain(argc, argv);
    }
}
EOF

cat > AppDelegate.h << 'EOF'
#import <Cocoa/Cocoa.h>
@interface AppDelegate : NSObject <NSApplicationDelegate>
@end
EOF

cat > AppDelegate.mm << 'EOF'
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:appMenuItem];
    [NSApp setMainMenu:mainMenu];

    // Sous-menu de l'app
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"App"];
    NSString *quitTitle = [NSString stringWithFormat:@"Quit %@", [[NSProcessInfo processInfo] processName]];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:quitTitle
        action:@selector(terminate:)
        keyEquivalent:@"q"];
    [appMenu addItem:quitItem];
    [appMenuItem setSubmenu:appMenu];


    const char *path = "/tmp/lancement.txt";
    FILE *fp = fopen(path, "w");
    if (fp) {
        fprintf(fp, "AppDelegate bien appelé !\n");
        fclose(fp);
    }

    // [NSApp terminate:nil];
}

@end
EOF

cat > Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Colorizer</string>
  <key>CFBundleIdentifier</key>
  <string>com.rodolphe.monapp</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
EOF

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(Colorizer LANGUAGES OBJCXX)

add_executable(Colorizer MACOSX_BUNDLE
    main.mm
    AppDelegate.mm
    AppDelegate.h
)

set_target_properties(Colorizer PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/Info.plist"
)

target_link_libraries(Colorizer "-framework Cocoa")
EOF

# echo "✅ Projet Cocoa minimal créé dans ./$APP_NAME"

