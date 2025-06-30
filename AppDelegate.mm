#import <opencv2/opencv.hpp>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "AppDelegate.h"
#import "OpenCVHelper.h"
#import "Image.h"

@implementation AppDelegate
cv::Mat _matSource;
cv::Mat _matBlackAndWhite;
cv::Mat _matColor;
//cv::Mat _matFusion;
cv::Mat _matBw32f;

- (void)createMenu {
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:appMenuItem];
    [NSApp setMainMenu:mainMenu];
    
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"App"];
    
    NSString *loadTitle = [NSString stringWithFormat:@"Load image"];
    NSMenuItem *loadItem = [[NSMenuItem alloc] initWithTitle:loadTitle action:@selector(openImageFromMenu)
                                               keyEquivalent:@"o"];
    [appMenu addItem:loadItem];
    
    NSString *quitTitle = [NSString stringWithFormat:@"Quit %@", [[NSProcessInfo processInfo] processName]];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                      action:@selector(terminate:)
                                               keyEquivalent:@"q"];
    [appMenu addItem:quitItem];
    [appMenuItem setSubmenu:appMenu];
}



//ImageBuffer *_bufferFusion;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    [self createMenu];
    
    // Create ImageView
    _imageView = [[NSImageView alloc] initWithFrame:_window.contentView.bounds];
    _imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    _imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [_window.contentView addSubview:_imageView];
    _imageDataAllocated = false;
    
    [self startMouseMonitor];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"releasing objects");
    
    if (_imageDataAllocated) {
        free(_imageData);
    }
    
    [_window release];
    _window = nil;
}


cv::Mat fusionVerticalSplit(const cv::Mat& mat1, const cv::Mat& mat2, int splitX, int separateurWidth = 3) {
    if (mat1.empty() || mat2.empty())
        throw std::runtime_error("Une ou les deux images sont vides");
    
    if (mat1.size() != mat2.size())
        throw std::runtime_error("Les deux images doivent avoir la même taille");
    
    if (mat1.type() != mat2.type())
        throw std::runtime_error("Les deux images doivent avoir le même type");
    
    if (splitX <= 0 || splitX >= mat1.cols)
        throw std::out_of_range("splitX doit être entre 1 et mat1.cols - 1");
    
    int height = mat1.rows;
    int width  = mat1.cols;
    
    int totalWidth = width + separateurWidth;
    cv::Mat fusion(height, totalWidth, mat1.type());
    
    // Partie gauche depuis mat1 [0, splitX)
    cv::Mat gaucheFusion = fusion(cv::Rect(0, 0, splitX, height));
    mat1(cv::Rect(0, 0, splitX, height)).copyTo(gaucheFusion);
    
    // Partie droite depuis mat2 [splitX, width)
    cv::Mat droiteFusion = fusion(cv::Rect(splitX + separateurWidth, 0, width - splitX, height));
    mat2(cv::Rect(splitX, 0, width - splitX, height)).copyTo(droiteFusion);
    
    // Bande de séparation blanche (ou pleine luminosité float)
    cv::rectangle(fusion, cv::Rect(splitX, 0, separateurWidth, height), cv::Scalar(1.0f, 1.0f, 1.0f), cv::FILLED);
    
    return fusion;
}


+ (NSURL *)URLByAppendingSuffix:(NSString *)suffix toFileURL:(NSURL *)url {
    if (!url.isFileURL) return nil;
    
    NSString *fileName = url.lastPathComponent;
    NSString *nameWithoutExt = [fileName stringByDeletingPathExtension];
    NSString *extension = fileName.pathExtension;
    
    NSString *newFileName = [NSString stringWithFormat:@"%@%@.%@", nameWithoutExt, suffix, extension];
    NSURL *directoryURL = [url URLByDeletingLastPathComponent];
    
    return [directoryURL URLByAppendingPathComponent:newFileName];
}



- (void)meltColorAndBw:(const cv::Mat &)bw32fCopy at:(int)x {
    cv::Mat fusion = fusionVerticalSplit(_matColor, bw32fCopy, x, 10);
    Image *i = [[Image alloc] initWithBGRCVMat:fusion];
    if (i) {
        _imageDataAllocated = true;
        NSImage *image = [i img];
        _imageView.image = image;
        if (!_window) {
            _window = [[NSWindow alloc]
                       initWithContentRect:NSMakeRect(100, 100, [image size].width, [image size].height)
                       styleMask:(NSWindowStyleMaskTitled |
                                  NSWindowStyleMaskResizable)
                       backing:NSBackingStoreBuffered
                       defer:NO];
        }
        
        [_window setContentView:_imageView];
        [_window makeKeyAndOrderFront:nil];
    } else {
        NSLog(@"Conversion NSImage échouée");
    }
    [i release];
}

- (void)openImageFromMenu {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    // panel.allowedFileTypes = @[@"png", @"jpg", @"jpeg", @"tiff"];
    panel.allowedContentTypes = @[UTTypePNG, UTTypeJPEG, UTTypeTIFF, UTTypeImage];
    panel.allowsMultipleSelection = NO;
    
    if ([panel runModal] == NSModalResponseOK) {
        NSURL *url = panel.URL;
        cv::Mat mat = cv::imread(url.path.UTF8String, cv::IMREAD_COLOR);
        if (mat.empty()) {
            NSLog(@"Échec du chargement OpenCV");
            return;
        }
        
        _matSource = mat;
        // bw conversion
        cv::Mat bwTemp;
        cv::cvtColor(_matSource, _matBlackAndWhite, cv::COLOR_BGR2GRAY);
        
        // write bw image before conversion
        // NSURL *bwUrl = [AppDelegate URLByAppendingSuffix:@"_bw" toFileURL:url];
        
        // colorize stuff
        OpenCVHelper *openCVHelper = [[OpenCVHelper alloc] init];
        NSString *protoPath = [[NSBundle mainBundle] pathForResource:@"neural/colorization_deploy_v2" ofType:@"prototxt"];
        NSString *neuralPath = [[NSBundle mainBundle] pathForResource:@"neural/colorization_release_v2" ofType:@"caffemodel"];
        
        printMatInfo("color", _matColor);
        printMatInfo("bw", _matBlackAndWhite);
        
        // Convert bw matrix to 32 bits float values
        cv::Mat bwColor;
        cv::cvtColor(_matBlackAndWhite, bwColor, cv::COLOR_GRAY2BGR);
        cv::Mat bw32f;
        bwColor.convertTo(bw32f, CV_32FC3); // bwColor is in 32 bits float
        
        printMatInfo("color", _matColor);
        printMatInfo("bw", bw32f);  // type 21 float32 3 canaux
        
        // here is the colorization from the bw matrix
        _matBw32f = bw32f.clone();  // copy because bw32f is modified in the function
        [openCVHelper colorizeWithBwMat:bw32f protoFile:[protoPath UTF8String] weightsFile:[neuralPath UTF8String] matrice:&_matColor];
        
        // colorization is done
        [OpenCVHelper release];
        
        cv::imwrite("color.jpg", _matColor);
        cv::imwrite("bw.jpg", bw32f);
        
        // fusion on 2 32 bits float matrix
        [self meltColorAndBw:_matBw32f at:_matColor.cols / 2];
        //[self startMouseMonitor];
    }
}

- (void)startMouseMonitor {
    mouseStateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                       target:self
                                                     selector:@selector(checkMouseState)
                                                     userInfo:nil
                                                      repeats:YES];
}

NSRect ImageFrameForImageView(NSImageView *imageView) {
    NSImage *image = imageView.image;
    if (!image) return NSZeroRect;
    
    NSSize viewSize = imageView.bounds.size;
    NSSize imageSize = image.size;
    
    CGFloat scale = MIN(viewSize.width / imageSize.width,
                        viewSize.height / imageSize.height);
    
    CGFloat displayW = imageSize.width * scale;
    CGFloat displayH = imageSize.height * scale;
    
    CGFloat originX = (viewSize.width - displayW) / 2.0;
    CGFloat originY = (viewSize.height - displayH) / 2.0;
    
    return NSMakeRect(originX, originY, displayW, displayH);
}

- (void)checkMouseState {
    
    if (!_window) {
        return;
    }
    
    if (!_imageView) {
        return;
    }
    
    // 2. Obtiens le cadre de l’image dans l’imageView
    NSRect imageFrameInView = ImageFrameForImageView(_imageView);
    
    // 3. Convertis vers coordonnées fenêtre
    NSRect imageFrameInWindow = [_imageView convertRect:imageFrameInView toView:nil];
    
    // 4. Convertis vers coordonnées écran
    NSRect imageFrameOnScreen = [_window convertRectToScreen:imageFrameInWindow];
    
    NSLog(@"🖼️ Image sur écran : x=%.0f y=%.0f w=%.0f h=%.0f",
          imageFrameOnScreen.origin.x,
          imageFrameOnScreen.origin.y,
          imageFrameOnScreen.size.width,
          imageFrameOnScreen.size.height);
    
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSLog(@"Souris : %.0f×%.0f",
          screenPoint.x, screenPoint.y);
    
    CGFloat dx = screenPoint.x - imageFrameOnScreen.origin.x;
    CGFloat dy = imageFrameOnScreen.size.height - (screenPoint.y - imageFrameOnScreen.origin.y); // car y=0 en haut
    
    if (dx > 0 && dx < imageFrameOnScreen.size.width &&
        dy > 0 && dy < imageFrameOnScreen.size.height) {
        
        NSImage *image = _imageView.image;
        CGFloat rx = dx / imageFrameOnScreen.size.width;
        CGFloat ry = dy / imageFrameOnScreen.size.height;
        
        CGFloat imgX = rx * image.size.width;
        CGFloat imgY = ry * image.size.height;
        
        NSLog(@"🖱️ Souris dans l’image : %.1f × %.1f (pixels de l’image réelle)", imgX, imgY);
        
        if (imgX >= 1 && imgX < _matColor.cols) {
            [self meltColorAndBw:_matBw32f at:imgX];
        }
        
    } else {
        NSLog(@"🕳️ La souris est en dehors de l’image");
    }
}




void printMatInfo(const std::string& label, const cv::Mat& mat) {
    NSLog(@"[%@] taille: %d x %d  |  type: %d  |  channels: %d  |  depth: %d",
          [NSString stringWithUTF8String:label.c_str()],
          mat.cols, mat.rows,
          mat.type(), mat.channels(), mat.depth());
}


@end
