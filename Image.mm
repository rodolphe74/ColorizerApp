//
//  Image.m
//  Colorizer
//
//  Created by Cordenie Rodolphe on 30/06/2025.
//

#import <opencv2/opencv.hpp>
#import "Image.h"

@implementation Image

- (nonnull instancetype)initWithBGRCVMat:(cv::Mat &)mat {
    
    self = [super init];
    if (self) {
        cv::Mat matRGB;
        cv::cvtColor(mat, matRGB, cv::COLOR_BGR2RGB);
        
        // 2. Clamp et convertit vers 8 bits
        cv::Mat matClamped;
        cv::min(matRGB, 255.0, matClamped);
        cv::max(matClamped, 0.0, matClamped);
        cv::Mat mat8U;
        matClamped.convertTo(mat8U, CV_8UC3);
        
        // 3. Copier les données (important pour éviter accès illégitime à .data plus tard)
        NSUInteger dataSize = mat8U.step[0] * mat8U.rows;
        _copiedData = (unsigned char *)malloc(dataSize);
        if (!_copiedData) return nullptr;
        memcpy(_copiedData, mat8U.data, dataSize);
        
        // 4. Créer la représentation bitmap à partir de la copie
        _rep = [[NSBitmapImageRep alloc]
               initWithBitmapDataPlanes:&_copiedData
               pixelsWide:mat8U.cols
               pixelsHigh:mat8U.rows
               bitsPerSample:8
               samplesPerPixel:3
               hasAlpha:NO
               isPlanar:NO
               colorSpaceName:NSCalibratedRGBColorSpace
               bytesPerRow:mat8U.step
               bitsPerPixel:24];
        
        if (!_rep) {
            free(_copiedData);
            return nullptr;
        }
        
        // 5. Créer l’image
        _img = [[NSImage alloc] initWithSize:NSMakeSize(mat8U.cols, mat8U.rows)];
        [_img addRepresentation:_rep];
    }
    return self;
}

- (void)dealloc {
    if (_copiedData) {
        free(_copiedData);
        _copiedData = NULL;
    }
    [_rep release];
    [_img release];
    [super dealloc];
}

- (NSImage *)img {
    return _img;
}

@end
