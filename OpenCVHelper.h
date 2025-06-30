//
//  OpenCVHelper.h
//  Colorizer
//
//  Created by Cordenie Rodolphe on 25/06/2025.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVHelper : NSObject
- (int) colorizeWithBwMat:(const cv::Mat &)img protoFile:(const char *)protoFilePath weightsFile:(const char *)weightsFilePath matrice:(cv::Mat *_Nonnull) matOut;
- (cv::Mat) fusionVerticalSplitWithMatColor:(const cv::Mat&)matColor andMatGray:(const cv::Mat&)matGray at:(int) splitX;
@end

NS_ASSUME_NONNULL_END
