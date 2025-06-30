//
//  Image.h
//  Colorizer
//
//  Created by Cordenie Rodolphe on 30/06/2025.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface Image : NSObject {
    unsigned char *_copiedData;
    NSImage *_img;
    NSBitmapImageRep *_rep;
}
- (instancetype)initWithBGRCVMat:(cv::Mat &) mat;
- (void)dealloc;
- (NSImage *)img;
@end

NS_ASSUME_NONNULL_END
